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
  parent::Union{Int64, Nothing}
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
  note_id::Union{Int64, Nothing}
  user_id::Int64
  upvote::Bool
  timestamp::Int64
end

