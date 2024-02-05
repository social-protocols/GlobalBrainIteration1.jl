struct Post
  id::Int64
  parent::Union{Int64, Nothing}
  # TODO:
  # timestamp::Int64 
end

# @enum VoteDirection up down

# struct Vote
#   post_id::Int64
#   note_id::Union{Int64, Nothing}
#   user_id::Int64
#   direction::VoteDirection
#   timestamp::Int64
# end

