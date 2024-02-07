"""
  Post

A post in a discussion thread. If `parent` is `nothing`, then this post is the
root of the thread.

# Fields

  * `id::Int64`: The unique identifier of the post.
  * `parent::Union{Int64, Nothing}`: The unique identifier of the parent post.
  * `timestamp::Int64`: The time at which the post was created.

# Constructors

```julia
Post(id::Int64, parent::Union{Int64, Nothing}, timestamp::Int64)
```

A keyword constructor is also available:

```julia
Post(; id::Int64, parent::Union{Int64, Nothing}, timestamp::Int64)
```

# Example

Post 2 which is a reply to post 1 and was created at time 3000:

```julia
Post(2, 1, 3000)
```

Alternatively:

```julia
Post(id = 2, parent = 1, timestamp = 3000)
```
"""
Base.@kwdef struct Post
  id::Int64
  parent::Union{Int64, Nothing}
  timestamp::Int64
end

Base.@kwdef struct Vote
  post_id::Int64
  note_id::Union{Int64, Nothing}
  user_id::Int64
  upvote::Bool
  timestamp::Int64
end

