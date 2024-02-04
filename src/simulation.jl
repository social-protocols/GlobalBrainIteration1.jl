function create_random_discussion(
  n_posts,
  max_votes_per_unit
)::Tuple{Tally, Vector{Post}, Dict{Int, Vector{InformedTally}}}
  random_discussion_tree = uniform_tree(n_posts)
  posts = vcat(
    [Post(1, nothing)],
    [Post(dst(e), src(e)) for e in edges(random_discussion_tree)]
  )
  total_count_1 = rand(1:max_votes_per_unit)
  success_count_1 = rand(1:total_count_1)
  total_count_2 = rand(1:max_votes_per_unit)
  success_count_2 = rand(1:total_count_2)
  total_count_3 = rand(1:max_votes_per_unit)
  success_count_3 = rand(1:total_count_3)
  informed_tallies = [
    InformedTally(
      p.parent,
      p.id,
      Tally(success_count_1, total_count_1),
      Tally(success_count_2, total_count_2),
      Tally(success_count_3, total_count_3)
    )
    for p in posts
    if !isnothing(p.parent)
  ]
  informed_tallies_dict = Dict(p.id => InformedTally[] for p in posts)
  for it in informed_tallies
    if haskey(informed_tallies_dict, it.post_id)
      push!(informed_tallies_dict[it.post_id], it)
    end
  end

  upvotes = rand(1:(max_votes_per_unit * n_posts))
  total_votes = rand(upvotes:(max_votes_per_unit * n_posts))
  post_tally = Tally(upvotes, total_votes)

  return (post_tally, posts, informed_tallies_dict)
end

