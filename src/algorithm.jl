Base.@kwdef struct InformedTally
  post_id::Int64
  note_id::Int64

  for_note::BernoulliTally
  for_post_given_not_shown_note::BernoulliTally
  for_post_given_shown_note::BernoulliTally
end

Base.@kwdef struct NoteEffect
  post_id::Int64
  note_id::Union{Int64, Nothing}
  p_given_not_shown_note::Float64
  p_given_shown_note::Float64
end

function magnitude(effect::Union{NoteEffect, Nothing})::Float64
  if isnothing(effect)
    return 0.0
  end
  return abs(effect.p_given_not_shown_note - effect.p_given_shown_note)
end

function calc_note_effect(tally::InformedTally)::NoteEffect
  p_given_not_shown_note =
    @chain GLOBAL_PRIOR_UPVOTE_PROBABILITY begin
      update(_, tally.for_post_given_not_shown_note)
      mle(_)
    end

  p_given_shown_note =
    @chain GLOBAL_PRIOR_UPVOTE_PROBABILITY begin
      update(_, tally.for_post_given_not_shown_note)
      reset_weight(_, WEIGHT_CONSTANT)
      update(_, tally.for_post_given_shown_note)
      mle(_)
    end

  return NoteEffect(
    post_id = tally.post_id,
    note_id = tally.note_id,
    p_given_not_shown_note = p_given_not_shown_note,
    p_given_shown_note = p_given_shown_note,
  )
end

function ratio_as_fraction(a::Number, b::Number)::Float64
  @assert(a > 0 && b > 0, "a and b must be positive")
  return a / (a + b)
end

function find_top_reply(
  post_id::Int,
  post_tally::BernoulliTally,
  informed_tallies::Dict{Int, Vector{InformedTally}}
)::NoteEffect
  tallies = informed_tallies[post_id]
  p_prior = @chain GLOBAL_PRIOR_UPVOTE_PROBABILITY begin
    update(_, post_tally)
    mle(_)
  end
  current_estimated_effect = NoteEffect(post_id, nothing, p_prior, p_prior)

  if isempty(tallies)
    return current_estimated_effect
  end

  for tally in tallies
    b_top_note_effect = find_top_reply(tally.note_id, tally.for_note, informed_tallies)
    support = ratio_as_fraction(
      b_top_note_effect.p_given_shown_note,
      b_top_note_effect.p_given_not_shown_note
    )

    a_this_note_effect = calc_note_effect(tally)

    if magnitude(a_this_note_effect) > magnitude(current_estimated_effect)
      p_of_a_given_shown_this_note_and_top_subnote =
        a_this_note_effect.p_given_shown_note * support
          + a_this_note_effect.p_given_not_shown_note * (1 - support)
      current_estimated_effect = NoteEffect(
        post_id,
        tally.note_id,
        a_this_note_effect.p_given_not_shown_note,
        p_of_a_given_shown_this_note_and_top_subnote,
      )
    end
  end

  return NoteEffect(
    post_id = post_id,
    note_id = current_estimated_effect.note_id,
    p_given_not_shown_note = current_estimated_effect.p_given_not_shown_note,
    p_given_shown_note = current_estimated_effect.p_given_shown_note,
  )
end

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
        support = ratio_as_fraction(
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


# ------------------------------------------------------------------------------
# --- Notes: -------------------------------------------------------------------
# ------------------------------------------------------------------------------

# We need the `InformedTally` for each post and reply in the thread.
# Task: How to formalize

