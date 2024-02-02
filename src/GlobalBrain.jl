module GlobalBrain

const WEIGHT_CONSTANT = 2.3

export Tally
export InformedTally

export BetaDistribution
export update
# export reset_weight
# export bayesian_avg_from_alpha_beta
# export alpha_beta_from_bayesian_avg

export GLOBAL_PRIOR_VOTE_RATE
export GLOBAL_PRIOR_UPVOTE_PROBABILITY

export calc_voterate

export Post
export Vote
export up
export down

export find_top_reply

using Chain

include("distributions.jl")
include("types.jl")
include("algorithm.jl")

end
