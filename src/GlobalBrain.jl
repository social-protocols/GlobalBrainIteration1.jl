module GlobalBrain

export Tally
export SimpleTally
export Distribution
export BetaDistribution
export update
export resetweight
export betadist_from_params
export params_from_betadist

export Post
export Vote
export up
export down


include("distributions.jl")
include("types.jl")
include("voterate.jl")

end
