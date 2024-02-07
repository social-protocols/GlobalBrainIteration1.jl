"""
  InformedTally

All tallies for a post/note combination.

# Fields

  * `post_id::Int64`: The unique identifier of the post.
  * `note_id::Int64`: The unique identifier of the note.
  * `for_note::BernoulliTally`: The tally for the note.
  * `for_post_given_not_shown_note::BernoulliTally`: The tally for the post
    given the note was not shown.
  * `for_post_given_shown_note::BernoulliTally`: The tally for the post given
    the note was shown.

# Constructors

```julia
InformedTally(
  post_id::Int64,
  note_id::Int64,
  for_note::BernoulliTally,
  for_post_given_not_shown_note::BernoulliTally,
  for_post_given_shown_note::BernoulliTally
)
```

A keyword constructor is also available:

```julia
InformedTally(;
  post_id::Int64,
  note_id::Int64,
  for_note::BernoulliTally,
  for_post_given_not_shown_note::BernoulliTally,
  for_post_given_shown_note::BernoulliTally
)
```

# Example

```julia
InformedTally(
  post_id = 1,
  note_id = 2,
  for_note = BernoulliTally(5, 6),
  for_post_given_not_shown_note = BernoulliTally(1, 4),
  for_post_given_shown_note = BernoulliTally(3, 5)
)
```
"""
Base.@kwdef struct InformedTally
  post_id::Int64
  note_id::Int64
  for_note::BernoulliTally
  for_post_given_not_shown_note::BernoulliTally
  for_post_given_shown_note::BernoulliTally
end

"""
  NoteEffect

The effect of a note on a post, given by the upvote probabilities given the
note was shown and not shown respectively.

# Fields

  * `post_id::Int64`: The unique identifier of the post.
  * `note_id::Union{Int64, Nothing}`: The unique identifier of the note. If
    `nothing`, then this is the root post.
  * `p_given_not_shown_note::Float64`: The probability of an upvote given the
    note was not shown.
  * `p_given_shown_note::Float64`: The probability of an upvote given the note
    was shown.
"""
Base.@kwdef struct NoteEffect
  post_id::Int64
  note_id::Union{Int64, Nothing}
  p_given_not_shown_note::Float64
  p_given_shown_note::Float64
end

"""
  magnitude(effect::Union{NoteEffect, Nothing})::Float64

Calculate the magnitude of a `NoteEffect`: the absolute difference between the
upvote probabilities given the note was shown and not shown respectively.

# Parameters

  * `effect::Union{NoteEffect, Nothing}`: The effect to calculate the magnitude
    of.
"""
function magnitude(effect::Union{NoteEffect, Nothing})::Float64
  if isnothing(effect)
    return 0.0
  end
  return abs(effect.p_given_not_shown_note - effect.p_given_shown_note)
end

"""
  calc_note_effect(tally::InformedTally)::NoteEffect

Calculate the effect of a note on a post from the informed tally for the note
and the post.

# Parameters

  * `tally::InformedTally`: The informed tallies for the note and the post.
"""
function calc_note_effect(tally::InformedTally)::NoteEffect
  p_given_not_shown_note = GLOBAL_PRIOR_UPVOTE_PROBABILITY |>
    (x -> update(x, tally.for_post_given_shown_note)) |>
    (x -> x.mean)

  p_given_shown_note = GLOBAL_PRIOR_UPVOTE_PROBABILITY |>
    (x -> update(x, tally.for_post_given_not_shown_note)) |>
    (x -> reset_weight(x, WEIGHT_CONSTANT)) |>
    (x -> update(x, tally.for_post_given_shown_note)) |>
    (x -> x.mean)

  return NoteEffect(
    post_id = tally.post_id,
    note_id = tally.note_id,
    p_given_not_shown_note = p_given_not_shown_note,
    p_given_shown_note = p_given_shown_note,
  )
end

"""
  calc_note_support(
    p_given_shown_note::Float64,
    p_given_not_shown_note::Float64
  )::Float64

Calculate the support for a note given the upvote probabilities given the note
was shown and not shown respectively.

# Parameters

  * `p_given_shown_note::Float64`: The probability of an upvote given the note
    was shown.
  * `p_given_not_shown_note::Float64`: The probability of an upvote given the
    note was not shown.
"""
function calc_note_support(
  p_given_shown_note::Float64,
  p_given_not_shown_note::Float64
)::Float64
  # TODO: this assert doesn't make sense conceptually -> handle p = 0 cases
  @assert(p_given_shown_note > 0 && p_given_not_shown_note > 0, "upvote probabilities must be positive")
  return p_given_shown_note / (p_given_shown_note + p_given_not_shown_note)
end

"""
  score_thread(
    root_post_id::Int,
    informed_tallies::Dict{Int, Vector{InformedTally}}
  )::Vector{NoteEffect}

Calculate (supported) scores for all post/note combinations in a thread.

# Parameters

  * `root_post_id::Int`: The unique identifier of the root post.
  * `informed_tallies::Dict{Int, Vector{InformedTally}}`: The informed tallies
    for the thread.
"""
function score_thread(
  root_post_id::Int,
  informed_tallies::Dict{Int, Vector{InformedTally}}
)::Vector{NoteEffect}
  tallies = informed_tallies[root_post_id]
  if isempty(tallies)
    return NoteEffect[]
  end
  return mapreduce(
    (tally) -> begin
      subnote_effects = score_thread(tally.note_id, informed_tallies)
      this_note_effect = calc_note_effect(tally)
      top_subnote_effect = reduce(
        (a, b) -> magnitude(a) > magnitude(b) ? a : b,
        subnote_effects;
        init = nothing
      )
      if isnothing(top_subnote_effect)
        return vcat(
          [
            NoteEffect(
              root_post_id,
              tally.note_id,
              this_note_effect.p_given_not_shown_note,
              this_note_effect.p_given_shown_note,
            )
          ],
          subnote_effects
        )
      else
        support = calc_note_support(
          top_subnote_effect.p_given_shown_note,
          top_subnote_effect.p_given_not_shown_note
        )
        p_given_shown_this_note_supported =
          this_note_effect.p_given_shown_note * support
            + this_note_effect.p_given_not_shown_note * (1 - support)
        return vcat(
          [
            NoteEffect(
              root_post_id,
              tally.note_id,
              this_note_effect.p_given_not_shown_note,
              p_given_shown_this_note_supported,
            )
          ],
          subnote_effects
        )
      end
    end,
    vcat,
    tallies
  )
end

"""
  find_top_reply(
    post_id::Int,
    informed_tallies::Dict{Int, Vector{InformedTally}}
  )::Union{NoteEffect, Nothing}

Find the top reply to a post in a thread.

# Parameters

  * `post_id::Int`: The unique identifier of the post.
  * `informed_tallies::Dict{Int, Vector{InformedTally}}`: The informed tallies
    for the thread.
"""
function find_top_reply(
  post_id::Int,
  informed_tallies::Dict{Int, Vector{InformedTally}}
)::Union{NoteEffect, Nothing}
  effects = score_thread(post_id, informed_tallies)
  if isempty(effects)
    return nothing
  end
  direct_children_effects = [n for n in effects if n.post_id == post_id]
  return reduce(
    (a, b) -> magnitude(a) > magnitude(b) ? a : b,
    direct_children_effects;
    init = nothing
  )
end

