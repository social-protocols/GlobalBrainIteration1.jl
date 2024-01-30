struct Post
  id::Int64
  parent::Union{Int64, Nothing}
end

@enum VoteDirection up down

struct Vote
  postid::Int64
  noteid::Union{Int64, Nothing}
  userid::Int64
  vote::VoteDirection
  timestamp::Int64
end

