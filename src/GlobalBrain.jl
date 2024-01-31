module GlobalBrain

const WEIGHT_CONSTANT = 2.3

export Tally
export SimpleTally
export Distribution
export BetaDistribution
export update
export resetweight
export betadist_from_params
export params_from_betadist
export GLOBAL_PRIOR_UPVOTE_PROBABILITY

export Post
export Vote
export up
export down

export calc_voterate

export InformedTally

include("distributions.jl")
include("types.jl")
include("voterate.jl")
include("algorithm.jl")

end
