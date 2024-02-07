module GlobalBrain

const WEIGHT_CONSTANT = 2.3

include("types.jl")
include("binary-entropy.jl")
include("probabilities.jl")
include("algorithm.jl")

# --- Exports from probabilities.jl
# ---------------------------------

export Model
export BetaBernoulli
export GammaPoisson
export Tally
export InformedTally
export Model
export BetaBernoulli
export GammaPoisson
export Tally
export BernoulliTally
export PoissonTally
export Distribution
export BetaDistribution
export GammaDistribution
export alpha
export beta
export update
export bayesian_avg
export reset_weight
export sample
export +
export -
export GLOBAL_PRIOR_VOTE_RATE
export GLOBAL_PRIOR_UPVOTE_PROBABILITY

# --- Exports from .BinaryEntropy
# -------------------------------

using .BinaryEntropy

export surprisal
export entropy
export cross_entropy
export relative_entropy
export information_gain

# --- Further exports
# -------------------

export Post
export Vote

export NoteEffect
export score_thread
export find_top_reply

end
