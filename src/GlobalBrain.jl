module GlobalBrain

import DBInterface
import Distributions
import SQLite
import Random
import Dates
import Turing
import MCMCChains
import Logging

include("types.jl")
include("constants.jl")
include("binary-entropy.jl")
include("scoredb.jl")
include("probabilities.jl")
include("algorithm.jl")
include("note-effect.jl")

# --- Exported types
# ------------------

export Post
export Vote

export Model
export BetaBernoulli
export GammaPoisson
export DetailedTally
export BernoulliTally
export PoissonTally
export Distribution
export BetaDistribution
export GammaDistribution
export alpha
export beta

export NoteEffect
export ScoreData

export TalliesTree
export SQLTalliesTree
export MemoryTalliesTree


# --- Exports from probabilities.jl
# ---------------------------------

export update
export bayesian_avg
export reset_weight
# export sample
export unpack
export +
export -



# --- Exports from .BinaryEntropy
# -------------------------------

using .BinaryEntropy

export surprisal
# export entropy
export cross_entropy
export relative_entropy
export information_gain


# --- Exports from scoredb.jl
# ---------------------------

export create_score_db_tables
export get_score_db
export to_detailed_tally
export get_detailed_tallies
export insert_score_data


# --- Exports from algorithm.jl
# -----------------------------

export score_tree
export get_score_data_db_writer

export update

export InMemoryTree

end
