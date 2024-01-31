abstract type Tally end

struct SimpleTally <: Tally
  success_count::Int
  total_count::Int
end

abstract type Distribution end

struct BetaDistribution <: Distribution
  mean::Float64
  weight::Float64
end

function update(dist::BetaDistribution, tally::SimpleTally)::BetaDistribution
  return BetaDistribution(
    (dist.mean * dist.weight + tally.success_count) / (dist.weight + tally.total_count),
    dist.weight + tally.total_count
  )
end

function resetweight(dist::BetaDistribution, new_weight::Float64)::BetaDistribution
  return BetaDistribution(dist.mean, new_weight)
end

function betadist_from_params(alpha::Float64, beta::Float64)::BetaDistribution
  return BetaDistribution(alpha / (alpha + beta), alpha + beta)
end

function params_from_betadist(dist::BetaDistribution)::Tuple{Float64, Float64}
  alpha = dist.mean * dist.weight
  return (alpha, dist.weight - alpha)
end

const GLOBAL_PRIOR_UPVOTE_PROBABILITY = BetaDistribution(0.875, WEIGHT_CONSTANT)

