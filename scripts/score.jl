using DataFrames


# uninformedTally = The tally of users who have not been exposed to note
# informedTally = The tally after user have been exposed to note
function score(informedTally::BernoulliTally, uninformedTally::BernoulliTally, selfTally::BernoulliTally)

	prior = GLOBAL_PRIOR_UPVOTE_PROBABILITY
	q = update(prior, uninformedTally)
	p = update(reset_weight(q, WEIGHT_CONSTANT), informedTally)

	pSelf = update(prior, selfTally)

	# Thomson Sampling: score based on a sample of p, q and pSelf.
	return score(sample(p), sample(q), sample(pSelf))
end


# The score for a post is calculated based on three values:
# p: the informed probability for parent of this post (given considered this note)
# q: the uninformed probability for parent of this post (given not considered this note)
# pSelf is informed upvoteProbability for current post
function score(p::BetaDistribution, q::BetaDistribution, pSelf::BetaDistribution)

	@assert(uninformedTally.sample_size >= 1, "uninformedTally.sample_size < 1")

	return
		pSelf * (1 + log(pSelf))
		+ relative_entropy(p, q)

	return DataFrame(
		p = p.mean,
		q = q.mean,
	)
end


df1 = incremental_information_gain(BernoulliTally(1,1), BernoulliTally(0,1))
df2 = incremental_information_gain(BernoulliTally(2,2), BernoulliTally(0,1))

# Compare this to the detailed example https://social-protocols.org/global-brain/cognitive-dissonance.html#detailed-example

df3 = incremental_information_gain(BernoulliTally(900,1000), BernoulliTally(100,500))

df = vcat(df1, df2, df3)
