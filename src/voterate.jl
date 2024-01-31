# ATTENTION:
# - attention is a number (here: Float64)
# - require protocol implementor to provide attention operationalized as a number
# - each implementor has to operationalize attention themselves, but we can provide a default
#
# VOTERATE:
# - also a number (here: Float64)
# - number of votes over the total attention on the post

function calc_voterate(tally::SimpleTally, attention::Float64)::Float64
  return update(
    GLOBAL_PRIOR_VOTE_RATE,
    SimpleTally(totalcount(tally), attention)
  ).avg
end

