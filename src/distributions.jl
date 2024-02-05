abstract type Model end
abstract type BetaBernoulli <: Model end
abstract type GammaPoisson <: Model end

struct Tally{T <: Model}
  count::Int
  sample_size::Int
  function Tally{T}(count::Int, sample_size::Int) where T
    @assert(count >= 0, "count cannot be smaller than 0")
    @assert(sample_size >= count, "sample_size cannot be smaller than count")
    new{T}(count, sample_size)
  end
end

struct Distribution{T <: Model}
  mean::Float64
  weight::Float64
end

const BernoulliTally = Tally{BetaBernoulli}
const BetaDistribution = Distribution{BetaBernoulli}

alpha(dist::BetaDistribution)::Float64 = dist.mean * dist.weight
beta(dist::BetaDistribution)::Float64 = (1 - dist.mean) * dist.weight

const PoissonTally = Tally{GammaPoisson}
const GammaDistribution = Distribution{GammaPoisson}

# We could define a generic update method for a Distribution and a Tally, but we don't want
# users to be able to update a Beta distribution with a Poisson tally and vice versa 
function update(prior::BetaDistribution, new_data::BernoulliTally)::BetaDistribution
  return BetaDistribution(
    bayesian_avg(prior, new_data),
    prior.weight + new_data.sample_size
  )
end

function update(prior::GammaDistribution, new_data::PoissonTally)::GammaDistribution
  return GammaDistribution(
    bayesian_avg(prior, new_data),
    prior.weight + new_data.sample_size
  )
end

# We can define the Bayesian average over any Distribution and Tally
function bayesian_avg(prior::Distribution, new_data::Tally)::Float64
    return (
      (prior.mean * prior.weight + new_data.count) 
        / (prior.weight + new_data.sample_size)
    )
end

function reset_weight(dist::Distribution, new_weight::Float64)
  T = typeof(dist)
  return T(dist.mean, new_weight)
end

function mle(dist::BetaDistribution)::Float64
  return dist.mean
end

function sample(dist::BetaDistribution)::Float64
  formal_dist = Beta(alpha(dist), beta(dist))
  return rand(formal_dist)
end

function sample(dist::GammaDistribution)::Float64
  formal_dist = Gamma(alpha(dist), 1 / beta(dist))
  return rand(formal_dist)
end

function Base.:+(a::Tally, b::Tally)
  T = typeof(a)
  @assert(T == typeof(b), "It only makes sense to add tallies of the same type")
  return T(a.count + b.count, a.sample_size + b.sample_size)
end

# function Base.:-(a::Tally, b::Tally)
#   T = typeof(a)
#   @assert(T == typeof(b), "It only makes sense to subtract tallies of the same type")
#   return T(a.count - b.count, a.sample_size - b.sample_size)
# end

function Base.:+(a::Tally, b::Tuple{Int, Int})
  T = typeof(a)
  return T(a.count + b[1], a.sample_size + b[2])
end

# Global prior on the vote rate (votes / attention). By definition the prior average is 1,
# because attention is calculated as the expected votes for the average post.
const GLOBAL_PRIOR_VOTE_RATE = BetaDistribution(1.0, WEIGHT_CONSTANT)

const GLOBAL_PRIOR_UPVOTE_PROBABILITY = BetaDistribution(0.875, WEIGHT_CONSTANT)


# ------------------------------------------------------------------------------
# --- Notes: -------------------------------------------------------------------
# ------------------------------------------------------------------------------

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
