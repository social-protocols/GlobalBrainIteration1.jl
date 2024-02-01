struct InformedTally
  post_id::Int64
  note_id::Union{Int64, Nothing}

  given_not_shown_this_note::UpDownTally
  given_shown_this_note::UpDownTally
  note_tally::UpDownTally
end

# We need the `InformedTally` for each post and reply in the thread.
# Task: How to formalize

function find_top_reply(
  post_tally::UpDownTally,
  informed_tallies::Vector{InformedTally}
)::Tuple{Int, Float64, Float64}
  p_of_a_given_not_shown_top_note = update(GLOBAL_PRIOR_UPVOTE_PROBABILITY, post_tally).avg
  p_of_a_given_shown_top_note = p_of_a_given_not_shown_top_note

  # TODO: handle empty case
  if isempty(informed_tallies)
    return (nothing, p_of_a_given_shown_top_note, p_of_a_given_not_shown_top_note)
  end

  for tally in informed_tallies
    (_, p_of_b_given_shown_top_subnote, p_of_b_given_not_shown_top_subnote) =
      find_top_reply(tally.note_tally, tally.informed_tallies)
    support = p_of_b_given_shown_top_subnote / p_of_b_given_not_shown_top_subnote

    p_of_a_given_not_shown_this_note =
      update(GLOBAL_PRIOR_UPVOTE_PROBABILITY, tally.given_not_shown_this_note).avg

    p_of_a_given_shown_this_note = @chain GLOBAL_PRIOR_UPVOTE_PROBABILITY begin
      update(_, tally.given_not_shown_this_note)
      reset_weight(_, WEIGHT_CONSTANT)
      update(_, tally.given_shown_this_note).avg
    end

    delta = p_of_a_given_shown_this_note - p_of_a_given_not_shown_this_note

    p_of_a_given_shown_this_note_and_top_subnote =
      p_of_a_given_not_shown_this_note + delta * support

    if (
      abs(p_of_a_given_shown_this_note_and_top_subnote - p_of_a_given_not_shown_this_note) >
      abs(p_of_a_given_shown_top_note - p_of_a_given_not_shown_top_note)
    )
      p_of_a_given_shown_top_note = p_of_a_given_shown_this_note_and_top_subnote
      p_of_a_given_not_shown_top_note = p_of_a_given_not_shown_this_note
      top_note_id = tally.note_id
    end
  end

  return (top_note_id, p_of_a_given_shown_top_note, p_of_a_given_not_shown_top_note)
end


