module GlobalBrain

import Random
import Distributions

const WEIGHT_CONSTANT = 2.3

include("distributions.jl")
include("types.jl")
include("algorithm.jl")
include("entropy.jl")

export Model
export BetaBernoulli
export GammaPoisson

export Tally
export InformedTally

export Distribution
export BetaDistribution
export GammaDistribution
export BernoulliTally
export PoissonTally
export update
export reset_weight
export alpha
export beta
export +
export -

export GLOBAL_PRIOR_VOTE_RATE
export GLOBAL_PRIOR_UPVOTE_PROBABILITY

# export calc_voterate

export Post
export Vote

export NoteEffect
export score_thread
export find_top_reply

# binary entropy
using .BinaryEntropy
export surprisal
export entropy
export cross_entropy
export relative_entropy
export information_gain

end
