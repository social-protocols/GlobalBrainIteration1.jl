struct UpDownTally
  upvotes::Int
  downvotes::Int
end

function total_count(tally::UpDownTally)::Int
  return tally.upvotes + tally.downvotes
end

struct VoteAttentionTally
  votes::Int
  units_of_attention::Float64
end

struct BayesianAverage{T}
  tally::T
  avg::Float64
  weight::Float64
end

function update(current_avg::BayesianAverage{UpDownTally}, tally::UpDownTally)::BayesianAverage{UpDownTally}
  updated_tally = UpDownTally(
    current_avg.tally.upvotes + tally.upvotes,
    current_avg.tally.downvotes + tally.downvotes
  )
  updated_weight = current_avg.weight + total_count(tally)
  return BayesianAverage(
    updated_tally,
    (current_avg.avg * current_avg.weight + tally.upvotes) / updated_weight,
    updated_weight
  )
end

function update(current_avg::BayesianAverage{VoteAttentionTally}, tally::VoteAttentionTally)::BayesianAverage{UpDownTally}
  updated_tally = VoteAttentionTally(
    current_avg.tally.votes + tally.votes,
    current_avg.tally.units_of_attention + tally.units_of_attention
  )
  updated_weight = current_avg.weight + tally.units_of_attention
  return BayesianAverage(
    updated_tally,
    (current_avg.avg * current_avg.weight + tally.votes) / updated_weight,
    updated_weight
  )
end

# ATTENTION:
# - attention is a number (here: Float64)
# - require protocol implementor to provide attention operationalized as a number
# - each implementor has to operationalize attention themselves, but we can provide a default
#
# VOTERATE:
# - also a number (here: Float64)
# - number of votes over the total attention on the post
function calc_voterate(tally::VoteAttentionTally)::Float64
  return update(GLOBAL_PRIOR_VOTE_RATE, tally).avg
end


# function reset_weight(avg::BayesianAverage, new_weight::Float64)::BayesianAverage
#   return BayesianAverage(avg.avg, new_weight)
# end

# function bayesian_avg_from_alpha_beta(alpha::Float64, beta::Float64)::BayesianAverage
#   return BayesianAverage(alpha / (alpha + beta), alpha + beta)
# end

# function alpha_beta_from_bayesian_avg(avg::BayesianAverage)::Tuple{Float64, Float64}
#   alpha = avg.avg * avg.weight
#   beta = avg.weight - alpha
#   return (alpha, beta)
# end

# Global prior on the vote rate (votes / attention). By definition the prior average is 1,
# because attention is calculated as the expected votes for the average post.
const GLOBAL_PRIOR_VOTE_RATE = BayesianAverage(VoteAttentionTally(1, 1.0), 1.0, WEIGHT_CONSTANT)

const GLOBAL_PRIOR_UPVOTE_PROBABILITY = BayesianAverage(UpDownTally(0, 0), 0.875, WEIGHT_CONSTANT)


