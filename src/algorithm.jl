struct InformedTally
  post_id::Int64
  note_id::Union{Int64, Nothing}

  for_note::Tally
  given_not_shown_this_note::Tally
  given_shown_this_note::Tally
end

# We need the `InformedTally` for each post and reply in the thread.
# Task: How to formalize

function find_top_reply(
  post_id::Int,
  post_tally::Tally,
  informed_tallies::Dict{Int, Array{InformedTally}}
)::Tuple{Union{Int, Nothing}, Float64, Float64}
  tallies = informed_tallies[post_id]
    
  p_of_a_given_not_shown_top_note =
    update(GLOBAL_PRIOR_UPVOTE_PROBABILITY, post_tally).mean
  p_of_a_given_shown_top_note = p_of_a_given_not_shown_top_note
  top_note_id = nothing

  # If there are no replies, the upvote rate only exists for the post without the
  # note. There is no note, thus note_id is `nothing`.
  if isempty(tallies)
    return (
      top_note_id, # nothing
      p_of_a_given_not_shown_top_note,
      p_of_a_given_not_shown_top_note
    )
  end

  for tally in tallies
    if isnothing(tally.note_id)
      continue
    end

    # RECURSION STARTS HERE!! -->
    (_, p_of_b_given_shown_top_subnote, p_of_b_given_not_shown_top_subnote) =
      find_top_reply(tally.note_id, tally.for_note, informed_tallies)
    support = (
      p_of_b_given_shown_top_subnote
        / (p_of_b_given_shown_top_subnote + p_of_b_given_not_shown_top_subnote)
    )

    p_of_a_given_not_shown_this_note =
      update(GLOBAL_PRIOR_UPVOTE_PROBABILITY, tally.given_not_shown_this_note).mean
    
    p_of_a_given_shown_this_note = @chain GLOBAL_PRIOR_UPVOTE_PROBABILITY begin
      update(_, tally.given_not_shown_this_note)
      reset_weight(_, WEIGHT_CONSTANT)
      update(_, tally.given_shown_this_note).mean
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

