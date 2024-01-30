abstract type Tally end

struct SimpleTally <: Tally
  upvotes::Int
  downvotes::Int
end

function totalcount(tally::SimpleTally)
  return tally.upvotes + tally.downvotes
end

abstract type Distribution end

struct BetaDistribution <: Distribution
  mean::Float64
  weight::Float64
end

function update(dist::BetaDistribution, tally::SimpleTally)
  return BetaDistribution(
    (dist.mean * dist.weight + totalcount(tally)) / (dist.weight + totalcount(tally)),
    dist.weight + totalcount(tally)
  )
end

function resetweight(dist::BetaDistribution, new_weight::Float64)
  return BetaDistribution(dist.mean, new_weight)
end

function beta_dist_from_params(alpha::Float64, beta::Float64)
  return BetaDistribution(alpha / (alpha + beta), alpha + beta)
end

function params_from_beta_dist(dist::BetaDistribution)
  alpha = dist.mean * dist.weight
  return (alpha, dist.weight - alpha)
end

