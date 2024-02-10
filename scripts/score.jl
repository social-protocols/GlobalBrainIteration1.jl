using DataFrames


prior = GLOBAL_PRIOR_UPVOTE_PROBABILITY

uninformedTally = BernoulliTally(1,1)
informedTally = BernoulliTally(0,1)
# deltaVotes = 1

q = update(prior, uninformedTally)

# In this scenario, we first only count the upvote of the original poster. The a single upvote increases the estimate above the global prior.
# But then we *reset* the prior weight and the estimate falls to below the global prior
bayesian_avg(reset_weight(q, WEIGHT_CONSTANT), informedTally)

# But in this scenario, we don't reset
bayesian_avg(q, informedTally)

# Which gives us the same results as
bayesian_avg(prior, uninformedTally+informedTally)

# uninformedTally = The tally of users who have not been exposed to note
# informedTally = The tally after user have been exposed to note

function score(informedTally::BernoulliTally, uninformedTally::BernoulliTally, selfTally::BernoulliTally)


	q = update(prior, uninformedTally)
	p = update(reset_weight(q, WEIGHT_CONSTANT), informedTally)

	pSelf = update(prior, selfTally)


	return score(sample(p), sample(q), sample(pSelf))

end



# The score for a post is calculated based on three values:
# p: the informed probability for parent of this post (given considered this note)
# q: the uninformed probability for parent of this post (given not considered this note)
# pSelf is informed upvoteProbability for current post
function score(p::BetaDistribution, q::BetaDistribution, pSelf::BetaDistribution)



	@assert(uninformedTally.sample_size >= 1, "uninformedTally.sample_size < 1")

	# so q is a tally of people who ARE uninformed OR WHO VOTED BEFORE BEING INFORMED.
	# total cognitive dissonance is just total relative entropy
	# q isn't expected to  change as people change votes as described in: https://social-protocols.org/global-brain/information-value.html
	# This doc should be updated.
	# The probabiliy of a changed vote does't change. It's still (p-q) / q.


	dkl = relative_entropy(p, q)

	return
		pSelf * (1 + log(pSelf))
		+ dkl


	# make a datafram with each of these values
	return DataFrame(
		p = p.mean,
		q = q.mean,
		upvotes = uninformedTally.count + informedTally.count,
		n = n,
		dkl = dkl,
		# cogdiss = cogdiss,
		# pNew = betaMean(pNew),
		# qNew = qNew,
		# nNew = nNew,
		# upvotesNew = uninformedTallyNew.count + informedTallyNew.count,
		# dklNew = dklNew,
		# cogdissNew = cogdissNew,
		# gain = total_information_gain
	)

end


# uninformedTally = BernoulliTally(2,2)
# informedTally = BernoulliTally(0,1)

df1 = incremental_information_gain(BernoulliTally(1,1), BernoulliTally(0,1))
df2 = incremental_information_gain(BernoulliTally(2,2), BernoulliTally(0,1))


# Compare this to the detailed example https://social-protocols.org/global-brain/cognitive-dissonance.html#detailed-example

# uninformedTally = BernoulliTally(900,1000)
# informedTally =BernoulliTally(100,500)

df3 = incremental_information_gain(BernoulliTally(900,1000), BernoulliTally(100,500))

df = vcat(df1, df2, df3)



# Okay what have I found here. A user being convinced increases cognitive dissonance. But that doesn't mean we want users to be convinced. 
# Our goal is not simply to reduce the cognitive dissonance metric. We want to change q to make it closer to p, because that makes users more informed. 
# But we don't want to change p to making it closer to q, or avoid making p further to q.
# So in this situation, since p is less than q, we believe that users given more information will likely change their vote, causing cognitive dissonance to increase.
# But this is not a loss to the system.

# probConvinced = (betaMean(q) - betaMean(p))/(betaMean(q))




# probGivenConvinced()
