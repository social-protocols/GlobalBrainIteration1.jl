import Random
import Distributions

"""
  Model

Abstract type for a probabilistic model.
"""
abstract type Model end

"""
  BetaBernoulli <: Model

Abstract type for a Beta-Bernoulli model.

See also [`Model`](@ref).
"""
abstract type BetaBernoulli <: Model end

"""
  GammaPoisson <: Model

Abstract type for a Gamma-Poisson model.

See also [`Model`](@ref).
"""
abstract type GammaPoisson <: Model end

"""
  Tally{T <: Model}

A tally for a given model. We count "successes" in trials, thus sample_size
must be greater or equal to count.

# Fields

  * `count::Int`: The number of positive outcomes in the sample.
  * `sample_size::Int`: The total number of outcomes in the sample.

See also [`Model`](@ref).
"""
struct Tally{T <: Model}
  count::Int
  sample_size::Int
  function Tally{T}(count::Int, sample_size::Int) where T
    @assert(count >= 0, "count cannot be smaller than 0")
    @assert(sample_size >= count, "sample_size cannot be smaller than count")
    new{T}(count, sample_size)
  end
end

"""
  Distribution{T <: Model}

A distribution for a given model, parameterized by mean and weight.

See also [`Model`](@ref).
"""
struct Distribution{T <: Model}
  mean::Float64
  weight::Float64
end

"""
  BernoulliTally

Short-hand for `Tally{BetaBernoulli}`.

See also [`Tally`](@ref), [`Model`](@ref).
"""
const BernoulliTally = Tally{BetaBernoulli}

"""
  BetaDistribution

Short-hand for `Distribution{BetaBernoulli}`.

See also [`Distribution`](@ref), [`Model`](@ref).
"""
const BetaDistribution = Distribution{BetaBernoulli}

"""
  alpha(dist::BetaDistribution)::Float64

Get the alpha parameter of a Beta distribution.

See also [`BetaDistribution`](@ref), [`beta`](@ref).
"""
alpha(dist::BetaDistribution)::Float64 = dist.mean * dist.weight

"""
  beta(dist::BetaDistribution)::Float64

Get the beta parameter of a Beta distribution.

See also [`BetaDistribution`](@ref), [`alpha`](@ref).
"""
beta(dist::BetaDistribution)::Float64 = (1 - dist.mean) * dist.weight

"""
  PoissonTally

Short-hand for `Tally{GammaPoisson}`.

See also [`Tally`](@ref), [`Model`](@ref).
"""
const PoissonTally = Tally{GammaPoisson}

"""
  GammaDistribution

Short-hand for `Distribution{GammaPoisson}`.

See also [`Distribution`](@ref), [`Model`](@ref).
"""
const GammaDistribution = Distribution{GammaPoisson}

"""
  update(prior::BetaDistribution, new_data::BernoulliTally)::BetaDistribution

Update a `BetaDistribution` with a `BernoulliTally`.

# Parameters

  * `prior::BetaDistribution`: The prior distribution.
  * `new_data::BernoulliTally`: New data to update the distribution with.

See also [`BetaDistribution`](@ref), [`BernoulliTally`](@ref).
"""
function update(prior::BetaDistribution, new_data::BernoulliTally)::BetaDistribution
  return BetaDistribution(
    bayesian_avg(prior, new_data),
    prior.weight + new_data.sample_size
  )
end

"""
  update(prior::GammaDistribution, new_data::PoissonTally)::GammaDistribution

Update a `GammaDistribution` with a `PoissonTally`.

# Parameters

  * `prior::GammaDistribution`: The prior distribution.
  * `new_data::PoissonTally`: New data to update the distribution with.

See also [`GammaDistribution`](@ref), [`PoissonTally`](@ref).
"""
function update(prior::GammaDistribution, new_data::PoissonTally)::GammaDistribution
  return GammaDistribution(
    bayesian_avg(prior, new_data),
    prior.weight + new_data.sample_size
  )
end

"""
  bayesian_avg(prior::Distribution, new_data::Tally)::Float64

Calculate the Bayesian average of a distribution with new data.

# Parameters

  * `prior::Distribution`: The prior distribution.
  * `new_data::Tally`: New data to update the distribution with.

See also [`Distribution`](@ref), [`Tally`](@ref).
"""
function bayesian_avg(prior::Distribution, new_data::Tally)::Float64
    return (
      (prior.mean * prior.weight + new_data.count) 
        / (prior.weight + new_data.sample_size)
    )
end

"""
  reset_weight(dist::Distribution, new_weight::Float64)::Distribution

Reset the weight of a distribution.

# Parameters

  * `dist::Distribution`: The distribution to reset the weight of.
  * `new_weight::Float64`: The new weight.

# Rationale

When we update an "uninformed" distribution with new "informed" data, the
weight needs to be reset because the prior distribution is the posterior
distribution of a previous update. Since we now get new information which
wasn't available at the time of the previous update, we need to reset the
weight.

See also [`Distribution`](@ref).
"""
function reset_weight(dist::Distribution, new_weight::Float64)
  T = typeof(dist)
  return T(dist.mean, new_weight)
end

"""
  sample(dist::BetaDistribution)::Float64

Draw a random sample from a `BetaDistribution`.

See also [`BetaDistribution`](@ref).
"""
function sample(dist::BetaDistribution)::Float64
  formal_dist = Distributions.Beta(alpha(dist), beta(dist))
  return Random.rand(formal_dist)
end

"""
  sample(dist::GammaDistribution)::Float64

Draw a random sample from a `GammaDistribution`.

See also [`GammaDistribution`](@ref).
"""
function sample(dist::GammaDistribution)::Float64
  formal_dist = Distributions.Gamma(alpha(dist), 1 / beta(dist))
  return Random.rand(formal_dist)
end

function Base.:+(a::Tally, b::Tally)
  T = typeof(a)
  @assert(T == typeof(b), "Tallies must be of the same type")
  return T(a.count + b.count, a.sample_size + b.sample_size)
end

function Base.:-(a::Tally, b::Tally)
  T = typeof(a)
  @assert(T == typeof(b), "Tallies must be of the same type")
  return T(a.count - b.count, a.sample_size - b.sample_size)
end

function Base.:+(a::Tally, b::Tuple{Int, Int})
  T = typeof(a)
  return T(a.count + b[1], a.sample_size + b[2])
end

function Base.:-(a::Tally, b::Tuple{Int, Int})
  T = typeof(a)
  return T(a.count - b[1], a.sample_size - b[2])
end

# Global prior on the vote rate (votes / attention). By definition the prior
# average is 1, because attention is calculated as the expected votes for the
# average post.
const GLOBAL_PRIOR_VOTE_RATE = BetaDistribution(1.0, WEIGHT_CONSTANT)

const GLOBAL_PRIOR_UPVOTE_PROBABILITY = BetaDistribution(0.875, WEIGHT_CONSTANT)

