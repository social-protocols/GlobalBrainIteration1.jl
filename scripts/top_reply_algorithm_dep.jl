using GlobalBrain

function find_top_reply(
  post_id::Int,
  post_tally::BernoulliTally,
  informed_tallies::Dict{Int, Vector{InformedTally}}
)::NoteEffect
  tallies = informed_tallies[post_id]
  p_prior = GLOBAL_PRIOR_UPVOTE_PROBABILITY |>
    (x -> update(x, post_tally)) |>
    (x -> x.mean)
  current_estimated_effect = NoteEffect(post_id, nothing, p_prior, p_prior)

  if isempty(tallies)
    return current_estimated_effect
  end

  for tally in tallies
    b_top_note_effect = find_top_reply(tally.note_id, tally.for_note, informed_tallies)
    support = GlobalBrain.ratio_as_fraction(
      b_top_note_effect.p_given_shown_note,
      b_top_note_effect.p_given_not_shown_note
    )

    a_this_note_effect = GlobalBrain.calc_note_effect(tally)

    if (
      GlobalBrain.magnitude(a_this_note_effect)
        > GlobalBrain.magnitude(current_estimated_effect)
    )
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
