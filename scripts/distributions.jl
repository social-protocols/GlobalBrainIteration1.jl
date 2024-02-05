# First, define abstract "Tally" and "Distribution types"
# Tally has a count and a sample_sample_size (e.g. number of trials or length of interval)
# And a distribution has a mean and a weight.


# Todo: can we define a "trait" or a "struct type" that defines what functions must be defined over distributions

abstract type Model end
abstract type BetaBernoulli <: Model end
abstract type GammaPoisson <: Model end

struct Tally{T<:Model}
  count::Int
  sample_size::Int
end

struct Distribution{T<:Model}
  mean::Float64
  weight::Float64
end

# We can define the Bayesian average over any Distribution and Tally
function bayesian_avg(prior::Distribution, new_data::Tally)::Float64
    return (prior.mean * prior.weight + new_data.count) / (prior.weight + new_data.sample_size)
end

function reset_weight(dist::Distribution, new_weight::Float64)
  T = typeof(dist)
  return T(dist.mean, new_weight)
end



# Now define the Beta-Bournoulli model

const BernoulliTally = Tally{BetaBernoulli}
const BetaDistribution = Distribution{BetaBernoulli}

# We could define a generic update method for a Distribution and a Tally, but we don't want
# users to be able to update a Beta distribution with a Poisson tally and vice versa 
function update(prior::BetaDistribution, new_data::BernoulliTally)::BetaDistribution
  return BetaDistribution(
    bayesian_avg(prior, new_data),
    prior.weight + new_data.sample_size
  )
end


# Now define the Gamma-Poisson model

const PoissonTally = Tally{GammaPoisson}
const GammaDistribution = Distribution{GammaPoisson}

function update(prior::GammaDistribution, new_data::PoissonTally)::GammaDistribution
  return GammaDistribution(
    bayesian_avg(prior, new_data),
    prior.weight + new_data.sample_size
  )
end

# WIP: And sampling methods

function alpha(dist::BetaDistribution)::Float64
  return dist.mean * dist.weight
end

function beta(dist::BetaDistribution)::Float64
  return (1 - dist.mean) * dist.weight
end

using Distributions, Random
function sample(dist::BetaDistribution)::Int
  d = Beta(alpha(dist),beta(dist))
  rand(d)
end

# TODO: same for gamma distrivution

# And some handy function for manipulating tallies

import Base: +, -

function +(a::Tally, b::Tally)
  T = typeof(a)
  @assert(T == typeof(b), "It only makes sense to add tallies of the same type")

  return T(a.count + b.count, a.sample_size + b.sample_size)
end

function -(a::Tally, b::Tally)
  T = typeof(a)
  @assert(T == typeof(b), "It only makes sense to subtract tallies of the same type")

  return T(a.count - b.count, a.sample_size - b.sample_size)
end


function +(a::Tally, b::Tuple{Int, Int})
  T = typeof(a)
  return T(a.count + b[1], a.sample_size + b[2])
end




const WEIGHT_CONSTANT = 2.3

# Global prior on the vote rate (votes / attention). By definition the prior average is 1,
# because attention is calculated as the expected votes for the average post.
const GLOBAL_PRIOR_VOTE_RATE = BetaDistribution(1.0, WEIGHT_CONSTANT)

const GLOBAL_PRIOR_UPVOTE_PROBABILITY = BetaDistribution(0.875, WEIGHT_CONSTANT)
