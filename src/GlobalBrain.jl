module GlobalBrain

const WEIGHT_CONSTANT = 2.3

export Tally
export SimpleTally
export BayesianAverage
export update
export resetweight
export bayesian_avg_from_alpha_beta
export alpha_beta_from_bayesian_avg
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
