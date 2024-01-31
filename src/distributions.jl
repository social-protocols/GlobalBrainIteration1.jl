abstract type Tally end

struct SimpleTally <: Tally
  successes::Int
  total::Int
end

abstract type Distribution end

struct BetaDistribution <: Distribution
  mean::Float64
  weight::Float64
end

function update(dist::BetaDistribution, tally::SimpleTally)
  return BetaDistribution(
    (dist.mean * dist.weight + tally.successes) / (dist.weight + tally.total),
    dist.weight + tally.total
  )
end

function resetweight(dist::BetaDistribution, new_weight::Float64)
  return BetaDistribution(dist.mean, new_weight)
end

function betadist_from_params(alpha::Float64, beta::Float64)
  return BetaDistribution(alpha / (alpha + beta), alpha + beta)
end

function params_from_betadist(dist::BetaDistribution)
  alpha = dist.mean * dist.weight
  return (alpha, dist.weight - alpha)
end

const GLOBAL_PRIOR_UPVOTE_PROBABILITY = BetaDistribution(0.875, WEIGHT_CONSTANT)

