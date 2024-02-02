# - NOTES ---
# -----------
# - Poisson tally, Bernoulli tally?
# - get distributions and sample them
# - dispatch update function for each type of tally?

struct Tally
  success_count::Int
  total_count::Int
end

struct BetaDistribution
  mean::Float64
  weight::Float64
end

function update(prior::BetaDistribution, new_data::Tally)::BetaDistribution
  return BetaDistribution(
    bayesian_avg(prior, new_data),
    prior.weight + new_data.total_count
  )
end

function bayesian_avg(prior::BetaDistribution, new_data::Tally)::Float64
  return (
    (prior.mean * prior.weight + new_data.success_count)
      / (prior.weight + new_data.total_count)
  )
end

# ATTENTION:
# - attention is a number (here: Float64)
# - require protocol implementor to provide attention operationalized as a number
# - each implementor has to operationalize attention themselves, but we can provide a default
#
# VOTERATE:
# - also a number (here: Float64)
# - number of votes over the total attention on the post
# function calc_voterate(vote_attention_tally::Tally)::Float64
#   return update(GLOBAL_PRIOR_VOTE_RATE, vote_attention_tally).avg
# end

function reset_weight(beta_dist::BetaDistribution, new_weight::Float64)::BetaDistribution
  return BetaDistribution(beta_dist.mean, new_weight)
end

# function bayesian_avg_from_alpha_beta(alpha::Float64, beta::Float64)::BayesianAverage
#   return BayesianAverage(alpha / (alpha + beta), alpha + beta)
# end

# function alpha_beta_from_bayesian_avg(avg::BayesianAverage)::Tuple{Float64, Float64}
#   alpha = avg.avg * avg.weight
#   beta = avg.weight - alpha
#   return (alpha, beta)
# end

# Global prior on the vote rate (votes / attention). By definition the prior average is 1,
# because attention is calculated as the expected votes for the average post.
const GLOBAL_PRIOR_VOTE_RATE = BetaDistribution(1.0, WEIGHT_CONSTANT)

const GLOBAL_PRIOR_UPVOTE_PROBABILITY = BetaDistribution(0.875, WEIGHT_CONSTANT)

