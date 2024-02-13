# Global prior on the vote rate (votes / attention). By definition the prior
# average is 1, because attention is calculated as the expected votes for the
# average post.
const GLOBAL_PRIOR_UPVOTE_PROBABILITY_SAMPLE_SIZE = C1 = 2.3

const GLOBAL_PRIOR_INFORMED_UPVOTE_PROBABILITY_SAMPLE_SIZE = C2 = 2.3

const GLOBAL_PRIOR_VOTE_RATE_SAMPLE_SIZE = 2.3

const GLOBAL_PRIOR_UPVOTE_PROBABILITY =
    BetaDistribution(0.875, GLOBAL_PRIOR_UPVOTE_PROBABILITY_SAMPLE_SIZE)

const GLOBAL_PRIOR_VOTE_RATE = BetaDistribution(1.0, 2.3)
