module GlobalBrain

export Tally
export SimpleTally
export totalcount
export Distribution
export BetaDistribution
export update
export resetweight
export beta_dist_from_params
export params_from_beta_dist

export Post
export Vote
export up
export down

include("distributions.jl")
include("types.jl")

end
