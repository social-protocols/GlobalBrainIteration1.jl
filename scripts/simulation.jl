function random_bernoulli_tally(size::Int)::BernoulliTally
  count = Random.rand(0:size)
  return BernoulliTally(count, size)
end

function create_random_discussion(
  n_posts::Int,
  max_votes_per_unit::Int,
)::Tuple{BernoulliTally, Vector{Post}, Dict{Int, Vector{DetailedTally}}}
  random_discussion_tree = uniform_tree(n_posts)
  posts = vcat(
    [Post(1, nothing)],
    [Post(dst(e), src(e)) for e in edges(random_discussion_tree)]
  )
  # total count -> random Poisson
  # success count -> random Bernoulli
  size = rand(1:max_votes_per_unit)
  informed_tallies = [
    DetailedTally(
      post_id = p.parent,
      note_id = p.id,
      for_note = random_bernoulli_tally(size),
      for_post_given_not_shown_note = random_bernoulli_tally(size),
      for_post_given_shown_note = random_bernoulli_tally(size)
    )
    for p in posts
    if !isnothing(p.parent)
  ]
  informed_tallies_dict = Dict(p.id => DetailedTally[] for p in posts)
  for it in informed_tallies
    if haskey(informed_tallies_dict, it.post_id)
      push!(informed_tallies_dict[it.post_id], it)
    end
  end

  upvotes = Random.rand(1:(max_votes_per_unit * n_posts))
  total_votes = Random.rand(upvotes:(max_votes_per_unit * n_posts))
  post_tally = BernoulliTally(upvotes, total_votes)

  return (post_tally, posts, informed_tallies_dict)
end

