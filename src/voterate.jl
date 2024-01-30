function calc_vote_rate(vote_history::Array{Vote})
  interval = maximum(vote_history.timestamp) - minimum(vote_history.timestamp)
  nvotes = length(vote_history)
  return nvotes / interval
end
