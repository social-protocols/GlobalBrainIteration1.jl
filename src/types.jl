"""
    Post

A post in a discussion thread. If `parent` is `nothing`, then this post is the
root of the thread.

# Fields

    * `id::Int64`: The unique identifier of the post.
    * `parent::Union{Int64, Nothing}`: The unique identifier of the parent post.
    * `timestamp::Int64`: The time at which the post was created.
"""
Base.@kwdef struct Post
    id::Int64
    parent::Union{Int64,Nothing}
    timestamp::Int64
end


"""
    Vote

A vote on a post. If `note_id` is `nothing`, then this vote is on the post
without a note being shown.

# Fields

    * `post_id::Int64`: The unique identifier of the post being voted on.
    * `note_id::Union{Int64, Nothing}`: The unique identifier of the note shown
    alongside the post, if any.
    * `user_id::Int64`: The unique identifier of the user who cast the vote.
    * `upvote::Bool`: Whether the vote is an upvote or a downvote.
    * `timestamp::Int64`: The time at which the vote was cast.
"""
Base.@kwdef struct Vote
    post_id::Int64
    note_id::Union{Int64,Nothing}
    user_id::Int64
    upvote::Bool
    timestamp::Int64
end


"""
    Model

Abstract type for a probabilistic model.
"""
abstract type Model end


"""
    BetaBernoulli <: Model

Abstract type for a Beta-Bernoulli model.

See also [`Model`](@ref).
"""
abstract type BetaBernoulli <: Model end


"""
    GammaPoisson <: Model

Abstract type for a Gamma-Poisson model.

See also [`Model`](@ref).
"""
abstract type GammaPoisson <: Model end


"""
    Tally{T <: Model}

A tally for a given model. We count "successes" in trials, thus sample_size
must be greater or equal to count.

# Fields

    * `count::Int`: The number of positive outcomes in the sample.
    * `sample_size::Int`: The total number of outcomes in the sample.

See also [`Model`](@ref).
"""
struct Tally{T<:Model}
    count::Int
    sample_size::Int
    function Tally{T}(count::Int, sample_size::Int) where {T}
        @assert(count >= 0, "count cannot be smaller than 0")
        @assert(sample_size >= count, "sample_size cannot be smaller than count")
        new{T}(count, sample_size)
    end
end


"""
    Distribution{T <: Model}

A distribution for a given model, parameterized by mean and weight.

See also [`Model`](@ref).
"""
struct Distribution{T<:Model}
    mean::Float64
    weight::Float64
end


"""
    BernoulliTally

Short-hand for `Tally{BetaBernoulli}`.

See also [`Tally`](@ref), [`Model`](@ref).
"""
const BernoulliTally = Tally{BetaBernoulli}


"""
    BetaDistribution

Short-hand for `Distribution{BetaBernoulli}`.

See also [`Distribution`](@ref), [`Model`](@ref).
"""
const BetaDistribution = Distribution{BetaBernoulli}


"""
    alpha(dist::BetaDistribution)::Float64

Get the alpha parameter of a Beta distribution.

See also [`BetaDistribution`](@ref), [`beta`](@ref).
"""
alpha(dist::BetaDistribution)::Float64 = dist.mean * dist.weight


"""
    beta(dist::BetaDistribution)::Float64

Get the beta parameter of a Beta distribution.

See also [`BetaDistribution`](@ref), [`alpha`](@ref).
"""
beta(dist::BetaDistribution)::Float64 = (1 - dist.mean) * dist.weight


"""
    PoissonTally

Short-hand for `Tally{GammaPoisson}`.

See also [`Tally`](@ref), [`Model`](@ref).
"""
const PoissonTally = Tally{GammaPoisson}


"""
    GammaDistribution

Short-hand for `Distribution{GammaPoisson}`.

See also [`Distribution`](@ref), [`Model`](@ref).
"""
const GammaDistribution = Distribution{GammaPoisson}


"""
    DetailedTally

All tallies for a post.

# Fields

    * `tag_id::Int64`: The tag id.
    * `parent_id::Union{Int64, Nothing}`: The unique identifier of the parent
    of this post if any.
    * `post_id::Int64`: The unique identifier of this post.
    * `parent::BernoulliTally`: The current tally tally for the **parent of
    this post**
    * `uninformed::BernoulliTally`: The tally for the **parent of this post**
    given user was not informed of this note.
    * `informed::BernoulliTally`: The tally for the **parent of this post**
    given user was informed of this note.
    * `self::BernoulliTally`: The current tally for this post.
"""
Base.@kwdef struct DetailedTally
    tag_id::Int64
    parent_id::Union{Int64,Nothing}
    post_id::Int64
    parent::BernoulliTally
    uninformed::BernoulliTally
    informed::BernoulliTally
    self::BernoulliTally
end


"""
    NoteEffect

The effect of a note on a post, given by the upvote probabilities given the
note was shown and not shown respectively.

# Fields

    * `post_id::Int64`: The unique identifier of the post.
    * `note_id::Union{Int64, Nothing}`: The unique identifier of the note. If
    `nothing`, then this is the root post.
    * `uninformed_probability::Float64`: The probability of an upvote given the
    note was not shown.
    * `informed_probability::Float64`: The probability of an upvote given the
    note was shown.
"""
Base.@kwdef struct NoteEffect
    post_id::Int64
    note_id::Union{Int64,Nothing}
    uninformed_probability::Float64
    informed_probability::Float64
end


# TODO: improve documentation
"""
    ScoreData

The data used to calculate the score of a post.
"""
Base.@kwdef struct ScoreData
    tag_id::Int64
    parent_id::Union{Int64,Nothing}
    post_id::Int64
    effect::Union{NoteEffect,Nothing}
    self_probability::Float64
    self_tally::BernoulliTally
    top_note_effect::Union{NoteEffect,Nothing}
end


"""
    TalliesTree

Abstract type for a tree of tallies. For any subtype of `TalliesTree`s, a
`children` and a `tally` method must be implemented. If none are found, the
default methods `children(t::TalliesTree)::Vector{TalliesTree}` and
`tally(t::TalliesTree)::DetailedTally` will raise an error.
"""
abstract type TalliesTree end


"""
    children(t::TalliesTree)::Vector{TalliesTree}

Default `children` method for `TalliesTree`. It throws an error since a
`children` method should be implemented for any subtype of `TalliesTree`.

See also [`TalliesTree`](@ref).
"""
function children(t::TalliesTree)
    @error "The children method is not implemented for type $(typeof(t))"
end


"""
    tally(t::TalliesTree)::DetailedTally

Default `tally` method for `TalliesTree`. It throws an error since a
`tally` method should be implemented for any subtype of `TalliesTree`.

See also [`TalliesTree`](@ref).
"""
function tally(t::TalliesTree)
    @error "The tally method is not implemented for type $(typeof(t))"
end


"""
    SQLTalliesTree <: TalliesTree

A data structure to represent a tree of tallies stored in an SQLite database.
"""
struct SQLTalliesTree <: TalliesTree
    tally::DetailedTally
    db::SQLite.DB
end


"""
    children(t::SQLTalliesTree)

Get the children of a `SQLTalliesTree`. As `SQLTalliesTree`s are stored in a
SQLite database, this function will query the database for the children.
"""
function children(t::SQLTalliesTree)::Base.Generator
    return get_detailed_tallies(t.db, t.tally.tag_id, t.tally.post_id)
end


"""
    tally(t::SQLTalliesTree)

Get the tally of a `SQLTalliesTree`.
"""
function tally(t::SQLTalliesTree)::DetailedTally
    return t.tally
end

# function tally(t::DetailedTally)
#     return t.self
# end

struct InMemoryTree <: TalliesTree
  tally::DetailedTally
  children::Vector{TalliesTree}
end

# Implement `children` and `tally` to make DetailedTally implement the (theoretical) TalliesTree interface

function children(t::InMemoryTree) return t.children end

function tally(t::InMemoryTree) return t.tally end

