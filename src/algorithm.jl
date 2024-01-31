struct InformedTally <: Tally
  postId::Int64
  noteId::Int64

  given_not_shown_this_note::SimpleTally
  given_shown_this_note::SimpleTally
  note_tally::SimpleTally
end

# We need the `InformedTally` for each post and reply in the thread.
# Task: How to formalize

function find_top_reply(
  post_tally::SimpleTally,
  informed_tallies::Vector{InformedTally}
)
  # if informed tallies empty
    # do something
  # else loop over informed tallies
    # recursively find top reply for each reply
      # calculate support
end


# export function findTopNoteGivenTallies(
# 	postId: number,
# 	postTally: Tally,
# 	subnoteTallies: Map<number, InformedTally[]>,
# ): [number | null, number, number] {
# 	let pOfAGivenNotShownTopNote =
# 		GLOBAL_PRIOR_UPVOTE_PROBABILITY.update(postTally).mean
# 
# 	let pOfAGivenShownTopNote = pOfAGivenNotShownTopNote
# 
# 	let topNoteId: number | null = null
# 
# 	const tallies = subnoteTallies.get(postId)
# 
# 	if (tallies == null) {
# 		// console.log(
# 		// 	`top note for post ${postId} is note ${topNoteId} with p=${pOfAGivenShownTopNote} and q=${pOfAGivenNotShownTopNote}`,
# 		// )
# 		// Bit of a hack. Should just get overall tally
# 		return [topNoteId, pOfAGivenShownTopNote, pOfAGivenNotShownTopNote]
# 	}
# 
# 	// loop over tallies
# 	for (const tally of tallies) {
# 		const [_, p_of_b_given_shown_top_subnote, pOfBGivenNotShownTopSubnote] =
# 			findTopNoteGivenTallies(tally.noteId, tally.forNote, subnoteTallies)
# 		const support = p_of_b_given_shown_top_subnote / pOfBGivenNotShownTopSubnote
# 
# 		const pOfAGivenNotShownThisNote = GLOBAL_PRIOR_UPVOTE_PROBABILITY.update(
# 			tally.givenNotShownThisNote,
# 		).mean
# 
# 		const pOfAGivenShownThisNote = GLOBAL_PRIOR_UPVOTE_PROBABILITY.update(
# 			tally.givenNotShownThisNote,
# 		)
# 			.resetWeight(WEIGHT_CONSTANT)
# 			.update(tally.givenShownThisNote).mean
# 		const delta = pOfAGivenShownThisNote - pOfAGivenNotShownThisNote
# 
# 		const pOfAGivenShownThisNoteAndTopSubnote =
# 			pOfAGivenNotShownThisNote + delta * support
# 
# 		// console.log(
# 		// 	`For post ${postId} and note ${tally.noteId}, pOfAGivenShownThisNote=${pOfAGivenShownThisNote}, pOfAGivenNotShownThisNote=${pOfAGivenNotShownThisNote}, delta=${delta}, support=${support}`,
# 		// )
# 
# 		if (
# 			Math.abs(
# 				pOfAGivenShownThisNoteAndTopSubnote - pOfAGivenNotShownThisNote,
# 			) > Math.abs(pOfAGivenShownTopNote - pOfAGivenNotShownTopNote)
# 		) {
# 			pOfAGivenShownTopNote = pOfAGivenShownThisNoteAndTopSubnote
# 			pOfAGivenNotShownTopNote = pOfAGivenNotShownThisNote
# 			topNoteId = tally.noteId
# 		}
# 	}
# 
# 	// console.log(
# 	// 	`\ttop note for post ${postId} is note ${topNoteId} with p=${pOfAGivenShownTopNote} and q=${pOfAGivenNotShownTopNote}`,
# 	// )
# 
# 	return [topNoteId, pOfAGivenShownTopNote, pOfAGivenNotShownTopNote]
# }


