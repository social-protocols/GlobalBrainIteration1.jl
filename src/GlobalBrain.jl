module GlobalBrain

include("types.jl")
include("binary-entropy.jl")
include("probabilities.jl")
include("constants.jl")
include("algorithm.jl")

# --- Exports from probabilities.jl
# ---------------------------------

export Model
export BetaBernoulli
export GammaPoisson
export Tally
export DetailedTally
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

# --- Exports from constants.jl
export GLOBAL_PRIOR_UPVOTE_PROBABILITY_SAMPLE_SIZE
export GLOBAL_PRIOR_UPVOTE_PROBABILITY
export GLOBAL_PRIOR_INFORMED_UPVOTE_PROBABILITY_SAMPLE_SIZE


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
export score_posts
export find_top_reply


end
