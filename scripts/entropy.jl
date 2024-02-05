

# Calculate entropy of a probability p: or to be technically correct the
# entropy Bernoulli distribution with parameter p
function entropy(p::Float64)::Float64
  if p == 1
    return 0
  end

  -(p * log2(p)) -(1-p)*log2(1-p)
end

# Calculate cross-entropy of probabilities p and q or to be technically
# correct: the cross-entropy of Bernoulli distributions with those parameters
function cross_entropy(p::Float64, q::Float64)::Float64
  if p == 1 && q == 1
    return 0
  end

  if p == 0 && q == 0
    return 0
  end

  -(p * log2(q)) -(1-p)*log2(1-q)
end


function relative_entropy(p::Float64, q::Float64)::Float64
	return cross_entropy(p, q) - entropy(p)
end

# Information gained from moving from belief q0 to q1 if "trueæ probability is p
function information_gain(p::Float64, q0::Float64, q1::Float64)::Float64
	return p * log2(q1/q0) + (1-p) * log2((1-q1)/(1-q0))
end








