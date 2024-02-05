module GlobalBrain

const WEIGHT_CONSTANT = 2.3

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
export up
export down

export find_top_reply

export create_random_discussion

export surprisal
export entropy
export cross_entropy
export relative_entropy
export information_gain

using Chain
using Graphs
using Random
using Distributions

include("distributions.jl")
include("types.jl")
include("algorithm.jl")
include("simulation.jl")
include("entropy.jl")

end
