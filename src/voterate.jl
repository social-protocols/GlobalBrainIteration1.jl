function calc_voterate(tally::SimpleTally, attention::Float64)
  return update(GLOBAL_PRIOR_UPVOTE_PROBABILITY, SimpleTally(tally.total, attention)).mean
end

# attention is a number (here: Float64)
# so require protocol implementor to provide attention operationalized as a number

