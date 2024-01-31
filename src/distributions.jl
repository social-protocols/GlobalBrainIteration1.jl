struct SimpleTally
  upvotes::Int
  downvotes::Int
end

function totalcount(tally::SimpleTally)::Int
  return tally.upvotes + tally.downvotes
end

struct BayesianAverage
  avg::Float64
  weight::Float64
end

function update(current_avg::BayesianAverage, tally::SimpleTally)::BayesianAverage
  return BayesianAverage(
    (current_avg.avg * current_avg.weight + tally.upvotes) / (current_avg.weight + totalcount(tally)),
    current_avg.weight + totalcount(tally)
  )
end

function resetweight(avg::BayesianAverage, new_weight::Float64)::BayesianAverage
  return BayesianAverage(avg.avg, new_weight)
end

function bayesian_avg_from_alpha_beta(alpha::Float64, beta::Float64)::BayesianAverage
  return BayesianAverage(alpha / (alpha + beta), alpha + beta)
end

function alpha_beta_from_bayesian_avg(avg::BayesianAverage)::Tuple{Float64, Float64}
  alpha = avg.avg * avg.weight
  beta = avg.weight - alpha
  return (alpha, beta)
end

const GLOBAL_PRIOR_UPVOTE_PROBABILITY = BayesianAverage(0.875, WEIGHT_CONSTANT)


# Global prior on the vote rate (votes / attention). By definition the prior average is 1,
# because attention is calculated as the expected votes for the average post.
const GLOBAL_PRIOR_VOTE_RATE = BayesianAverage(1, WEIGHT_CONSTANT)
