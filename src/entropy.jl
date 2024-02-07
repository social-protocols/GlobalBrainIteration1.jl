module BinaryEntropy

export surprisal
export entropy
export cross_entropy
export relative_entropy
export information_gain

function surprisal(p::Float64, unit::Int = 2)::Float64
  @assert(1 >= p > 0, "p must be in (0, 1]")
  return log(unit, 1 / p)
end

# Calculate entropy of a probability p: or to be technically correct the
# entropy Bernoulli distribution with parameter p
function entropy(p::Float64)::Float64 
  @assert(1 >= p > 0, "p must be in (0, 1]")
  return (
    p == 1
      ? 0
      : p * surprisal(p, 2) + (1 - p) * surprisal(1 - p, 2)
  )
end

# Calculate cross-entropy of probabilities p and q or to be technically
# correct: the cross-entropy of Bernoulli distributions with those parameters
function cross_entropy(p::Float64, q::Float64)::Float64
  return (
    ((p == 1.0) && (q == 1.0)) || ((p == 0.0) && (q == 0.0))
      ? 0
      : p * surprisal(q, 2) + (1 - p) * surprisal(1 - q, 2)
  )
end

function relative_entropy(p::Float64, q::Float64)::Float64
	return cross_entropy(p, q) - entropy(p)
end

# Information gained from moving from belief q0 to q1 if "true" probability is p
function information_gain(p::Float64, q0::Float64, q1::Float64)::Float64
	return p * log2(q1/q0) + (1-p) * log2((1-q1)/(1-q0))
end

end

