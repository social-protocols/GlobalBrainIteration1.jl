using DataFrames


prior = GLOBAL_PRIOR_UPVOTE_PROBABILITY

uninformedTally = BernoulliTally(1,1)
informedTally = BernoulliTally(0,1)
deltaVotes = 1

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

function incremental_information_gain(uninformedTally::BernoulliTally, informedTally::BernoulliTally, deltaVotes::Int)

	@assert(uninformedTally.sample_size >= 1, "uninformedTally.sample_size < 1")


	q = update(prior, uninformedTally)
	# qAgain = uninformedTally.count/uninformedTally.sample_size

	p = update(reset_weight(q, WEIGHT_CONSTANT), informedTally)

	# Calculate the cognitive dissonance among uninformed users only
	n = uninformedTally.sample_size
	upvotes = uninformedTally.count


	dkl = relative_entropy(p.mean, q.mean)
	cogdiss = n * dkl

	# Now hypothetical situation given submitter is shown note
	# Consider the same set of n users. Calculate their average belief qNew
	# uninformedTallyNew = BernoulliTally(upvotes-deltaVotes,n)
	uninformedTallyNew = uninformedTally + (-deltaVotes,0)

	qNew = update(prior, uninformedTallyNew)


	dklNew = relative_entropy(p.mean, qNew.mean)
	cogdissNew = n * dklNew

	# Same result
	# cogdiss - cogdissNew

	# Again Same result
	# n * (
	# 	relative_entropy(p, q)
	# 	- relative_entropy(p, qNew)
	# )


	# Formula from https://social-protocols.org/global-brain/information-value.html
	# that formula multiplies by votesTotal, where we multiply by which is the number of unformed votes
	# total_information_gain = n * information_gain(p, q, qNew)
	# TODO: This should be our final scoring function I think
	# return
		# upvote_probability_note * (1 + log(upvote_probability_note))
		# + information_gain(upvote_probability_post, uninformed_upvote_probability_post, qNew)



	# make a datafram with each of these values
	return DataFrame(
		p = p,
		q = q,
		upvotes = uninformedTally.count + informedTally.count,
		n = n,
		dkl = dkl,
		cogdiss = cogdiss,
		# pNew = betaMean(pNew),
		qNew = qNew,
		# nNew = nNew,
		# upvotesNew = uninformedTallyNew.count + informedTallyNew.count,
		dklNew = dklNew,
		cogdissNew = cogdissNew,
		gain = information_gain
	)

end




# uninformedTally = BernoulliTally(2,2)
# informedTally = BernoulliTally(0,1)

df1 = incremental_information_gain(BernoulliTally(1,1), BernoulliTally(0,1), 1)
df2 = incremental_information_gain(BernoulliTally(2,2), BernoulliTally(0,1), 1)


# Compare this to the detailed example https://social-protocols.org/global-brain/cognitive-dissonance.html#detailed-example

# uninformedTally = BernoulliTally(900,1000)
# informedTally =BernoulliTally(100,500)

df3 = incremental_information_gain(BernoulliTally(900,1000), BernoulliTally(100,500), 70)

df = vcat(df1, df2, df3)



# Okay what have I found here. A user being convinced increases cognitive dissonance. But that doesn't mean we want users to be convinced. 
# Our goal is not simply to reduce the cognitive dissonance metric. We want to change q to make it closer to p, because that makes users more informed. 
# But we don't want to change p to making it closer to q, or avoid making p further to q.
# So in this situation, since p is less than q, we believe that users given more information will likely change their vote, causing cognitive dissonance to increase.
# But this is not a loss to the system.

# probConvinced = (betaMean(q) - betaMean(p))/(betaMean(q))




# probGivenConvinced()
