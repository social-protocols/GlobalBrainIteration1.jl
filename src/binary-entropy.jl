module BinaryEntropy

export surprisal
export entropy
export cross_entropy
export relative_entropy
export information_gain

"""
  surprisal(p::Float64, unit::Int = 2)::Float64

Calculate the surprisal of an event drawn from a Bernoulli distribution with
parameter p. The default unit is 2, which means the result is in bits.

# Parameters

  * `p::Float64`: The parameter of the Bernoulli distribution.
  * `unit::Int`: The informational unit of the result.
"""
function surprisal(p::Float64, unit::Int = 2)::Float64
  @assert(1 >= p > 0, "p must be in (0, 1]")
  return log(unit, 1 / p)
end

"""
  entropy(p::Float64)::Float64

Calculate the entropy of a Bernoulli distribution with parameter p.

# Parameters

  * `p::Float64`: The parameter of the Bernoulli distribution.
"""
function entropy(p::Float64)::Float64 
  @assert(1 >= p > 0, "p must be in (0, 1]")
  return (
    p == 1
      ? 0
      : p * surprisal(p, 2) + (1 - p) * surprisal(1 - p, 2)
  )
end

"""
  cross_entropy(p::Float64, q::Float64)::Float64

Calculate the cross-entropy of Bernoulli distributions with parameters p and q.

# Parameters

  * `p::Float64`: The parameter of the first Bernoulli distribution.
  * `q::Float64`: The parameter of the second Bernoulli distribution.

"""
function cross_entropy(p::Float64, q::Float64)::Float64
  return (
    ((p == 1.0) && (q == 1.0)) || ((p == 0.0) && (q == 0.0))
      ? 0
      : p * surprisal(q, 2) + (1 - p) * surprisal(1 - q, 2)
  )
end

"""
  relative_entropy(p::Float64, q::Float64)::Float64

Calculate the relative entropy of Bernoulli distributions with parameters p and q.

# Parameters

  * `p::Float64`: The parameter of the first Bernoulli distribution.
  * `q::Float64`: The parameter of the second Bernoulli distribution.
"""
function relative_entropy(p::Float64, q::Float64)::Float64
	return cross_entropy(p, q) - entropy(p)
end

"""
  information_gain(p::Float64, q0::Float64, q1::Float64)::Float64

Calculate the information gain from moving from a belief with parameter q0 to a
belief with parameter q1, given that the true probability is p.

# Parameters

  * `p::Float64`: The true probability.
  * `q0::Float64`: The parameter of the initial belief.
  * `q1::Float64`: The parameter of the final belief.
"""
function information_gain(p::Float64, q0::Float64, q1::Float64)::Float64
	return p * log2(q1 / q0) + (1 - p) * log2((1 - q1) / (1 - q0))
end

end

