
"""
  NoteEffect

The effect of a note on a post, given by the upvote probabilities given the
note was shown and not shown respectively.

# Fields

  * `post_id::Int64`: The unique identifier of the post.
  * `note_id::Union{Int64, Nothing}`: The unique identifier of the note. If
    `nothing`, then this is the root post.
  * `uninformed_probability::Float64`: The probability of an upvote given the
    note was not shown.
  * `informed_probability::Float64`: The probability of an upvote given the note
    was shown.
"""
Base.@kwdef struct NoteEffect
  post_id::Int64
  note_id::Union{Int64, Nothing}
  uninformed_probability::Float64
  informed_probability::Float64
end

Base.@kwdef struct ScoreData
  parent_id::Union{Int64, Nothing}
  effect::Union{NoteEffect, Nothing}
  post_id::Int64
  top_note_effect::Union{NoteEffect, Nothing}
end


"""
  magnitude(effect::Union{NoteEffect, Nothing})::Float64

Calculate the magnitude of a `NoteEffect`: the absolute difference between the
upvote probabilities given the note was shown and not shown respectively. The
effect of `Nothing` is 0.0 by definition.

# Parameters

  * `effect::Union{NoteEffect, Nothing}`: The effect to calculate the magnitude
    of.
"""
function magnitude(effect::Union{NoteEffect, Nothing})::Float64
  return abs(effect.uninformed_probability - effect.informed_probability)
end


"""
  calc_note_effect(tally::DetailedTally)::NoteEffect

Calculate the effect of a note on a post from the informed tally for the note
and the post.

# Parameters

  * `tally::DetailedTally`: The informed tallies for the note and the post.
"""
function calc_note_effect(tally::DetailedTally)::NoteEffect
  uninformed_probability = GLOBAL_PRIOR_UPVOTE_PROBABILITY |>
    (x -> update(x, tally.uninformed)) |>
    (x -> x.mean)

  informed_probability = GLOBAL_PRIOR_UPVOTE_PROBABILITY |>
    (x -> update(x, tally.uninformed)) |>
    (x -> reset_weight(x, GLOBAL_PRIOR_INFORMED_UPVOTE_PROBABILITY_SAMPLE_SIZE)) |>
    (x -> update(x, tally.informed)) |>
    (x -> x.mean)

  return NoteEffect(
    post_id = tally.parent_id,
    note_id = tally.post_id,
    uninformed_probability = uninformed_probability,
    informed_probability = informed_probability,
  )
end

"""
  calc_note_support(
    informed_probability::Float64,
    uninformed_probability::Float64
  )::Float64

Calculate the support for a note given the upvote probabilities given the note
was shown and not shown respectively.

# Parameters

  * `informed_probability::Float64`: The probability of an upvote given the note
    was shown.
  * `uninformed_probability::Float64`: The probability of an upvote given the
    note was not shown.
"""
function calc_note_support(
  informed_probability::Float64,
  uninformed_probability::Float64
)::Float64
  # TODO: this assert doesn't make sense conceptually -> handle p = 0 cases
  @assert(informed_probability > 0 && uninformed_probability > 0, "upvote probabilities must be positive")
  return informed_probability / (informed_probability + uninformed_probability)
end

"""
  score_posts(
    parent_id::Int,
    tallies}
  )::Vector{NoteEffect}

Calculate (supported) scores for all post/note combinations in a thread.

# Parameters

  * `parent_id::Union{Int, Nothing}`: The unique identifier of the root post, or nothing for top-level posts
  * `tallies}`: The informed tallies
    for the thread.
"""

function score_posts(
  tallies
)::Vector{ScoreData}

  return mapreduce(
    (t) -> begin

      tally = t.tally

      subnote_score_data = score_posts(children(t))

      this_note_effect = (tally.parent_id === nothing) ? nothing : calc_note_effect(tally)

      # Find the top subnote
      top_subnote_effect = reduce(
        (a, b) -> begin 
            ma = (a === nothing) ? 0 : magnitude(a)
            mb = (b === nothing) ? 0 : magnitude(b)
            ma > mb ? a : b 
        end, 
        [x.effect for x in subnote_score_data if x.parent_id === tally.post_id];
        init = nothing
      )


      this_note_effect_supported = isnothing(this_note_effect) ? nothing : begin
          informed_probability_supported = 
            isnothing(top_subnote_effect) ? 
            this_note_effect.informed_probability : 
            begin
              support = calc_note_support(
                top_subnote_effect.informed_probability,
                top_subnote_effect.uninformed_probability
              )

              this_note_effect.informed_probability * support + this_note_effect.uninformed_probability * (1 - support)
            end
        something(NoteEffect(
          this_note_effect.post_id, 
          this_note_effect.note_id,
          this_note_effect.uninformed_probability,
          informed_probability_supported,
        ), nothing)
      end


      this_score_data = ScoreData(
        tally.parent_id, 
        this_note_effect_supported,
        tally.post_id,
        top_subnote_effect,
      )

      return vcat([this_score_data], subnote_score_data)
    end,
    vcat,
    tallies;
    init = []
  )
end




