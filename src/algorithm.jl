struct InformedTally
  post_id::Int64
  note_id::Int64

  for_note::BernoulliTally
  given_not_shown_this_note::BernoulliTally
  given_shown_this_note::BernoulliTally
end

struct NoteEstimate
  post_id::Int64
  note_id::Union{Int64, Nothing}
  p_given_not_shown_note::Float64
  p_given_shown_note::Float64
end

function estimate_note_diff(estimate::NoteEstimate)::Float64
  return abs(estimate.p_given_not_shown_note - estimate.p_given_shown_note)
end

function calc_note_estimate(tally::InformedTally)::NoteEstimate
  p_given_not_shown_note =
    @chain GLOBAL_PRIOR_UPVOTE_PROBABILITY begin
      update(_, tally.given_not_shown_this_note)
      mle(_)
    end

  p_given_shown_note = @chain GLOBAL_PRIOR_UPVOTE_PROBABILITY begin
    update(_, tally.given_not_shown_this_note)
    reset_weight(_, WEIGHT_CONSTANT)
    update(_, tally.given_shown_this_note)
    mle(_)
  end

  return NoteEstimate(
    tally.post_id,
    tally.note_id,
    p_given_not_shown_note,
    p_given_shown_note
  )
end

function calc_thread_level_prior_note_estimate(
  post_id::Int,
  post_tally::Tally
)::NoteEstimate
  p_of_a_given_not_shown_top_note = p_of_a_given_shown_top_note =
    @chain GLOBAL_PRIOR_UPVOTE_PROBABILITY begin
      update(_, post_tally)
      mle(_)
    end
  top_note_id = nothing
  return NoteEstimate(
    post_id,
    top_note_id,
    p_of_a_given_not_shown_top_note,
    p_of_a_given_shown_top_note
  )
end

function find_top_reply(
  post_id::Int,
  post_tally::BernoulliTally,
  informed_tallies::Dict{Int, Vector{InformedTally}}
)::NoteEstimate
  tallies = informed_tallies[post_id]
  current_estimate = calc_thread_level_prior_note_estimate(post_id, post_tally)

  if isempty(tallies)
    return current_estimate
  end

  for tally in tallies
    b_top_note = find_top_reply(tally.note_id, tally.for_note, informed_tallies)
    support = (
      b_top_note.p_given_shown_note
        / (b_top_note.p_given_shown_note + b_top_note.p_given_not_shown_note)
    )

    a_this_note = calc_note_estimate(tally)
    p_of_a_given_shown_this_note_and_top_subnote =
      a_this_note.p_given_shown_note * support
        + a_this_note.p_given_not_shown_note * (1 - support)

    if estimate_note_diff(a_this_note) > estimate_note_diff(current_estimate)
      current_estimate = NoteEstimate(
        post_id,
        tally.note_id,
        a_this_note.p_given_not_shown_note,
        p_of_a_given_shown_this_note_and_top_subnote,
      )
    end
  end

  return NoteEstimate(
    post_id,
    current_estimate.note_id,
    current_estimate.p_given_not_shown_note,
    current_estimate.p_given_shown_note,
  )
end


# ------------------------------------------------------------------------------
# --- Notes: -------------------------------------------------------------------
# ------------------------------------------------------------------------------

# We need the `InformedTally` for each post and reply in the thread.
# Task: How to formalize

