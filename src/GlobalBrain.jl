module GlobalBrain

import DBInterface
import Distributions
import SQLite
import Random

include("types.jl")
include("constants.jl")
include("binary-entropy.jl")
include("scoredb.jl")
include("probabilities.jl")
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
# -----------------------------

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


# --- Exports from scoredb.jl
# ---------------------------

export get_score_db
export to_detailed_tally
export get_detailed_tallies
export insert_score_data


# --- Further exports
# -------------------

export Post
export Vote

export NoteEffect
export score_posts

export TalliesTree
export ScoreData

end
