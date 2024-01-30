struct Post
  id::Int64
  parent::Union{Int64, Nothing}
end

struct Vote
  postid::Int64
  userid::Int64
  vote::VoteDirection
  timestamp::Int64
end

@enum VoteDirection up=1 down=-1 
