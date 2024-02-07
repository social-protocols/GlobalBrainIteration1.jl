using GlobalBrain

# --- Discussion tree:
# 1
# |-2
#   |-4
#   |-5
# |-3
#   |-6
#     |-7
posts = [
  Post(1, nothing),
  Post(2, 1),
  Post(3, 1),
  Post(4, 2),
  Post(5, 2),
  Post(6, 3),
  Post(7, 6),
]

# post_tally = BernoulliTally(26, 51)

informed_tallies_vec = [
  InformedTally(1, 2, BernoulliTally(5, 10), BernoulliTally(8, 14), BernoulliTally(6, 9)),
  InformedTally(1, 3, BernoulliTally(8, 11), BernoulliTally(9, 16), BernoulliTally(1, 13)),
  InformedTally(2, 4, BernoulliTally(12, 12), BernoulliTally(8, 9), BernoulliTally(0, 10)),
  InformedTally(2, 5, BernoulliTally(5, 7), BernoulliTally(5, 6), BernoulliTally(7, 13)),
  InformedTally(3, 6, BernoulliTally(3, 4), BernoulliTally(5, 8), BernoulliTally(2, 3)),
  InformedTally(6, 7, BernoulliTally(8, 15), BernoulliTally(7, 10), BernoulliTally(3, 15)),
]

informed_tallies = Dict(p.id => InformedTally[] for p in posts)
for it in informed_tallies_vec
  if haskey(informed_tallies, it.post_id)
    push!(informed_tallies[it.post_id], it)
  end
end

println("--------------")
println("Informed tallies: ")
for k in sort(collect(keys(informed_tallies)))
  println(k, ":")
  for it in informed_tallies[k]
    println(it)
  end
end

println("--------------")
println("Starting computation...")
estimate = score_thread(1, informed_tallies)

println("--------------")
println("Results: ")
for e in estimate
  println(e)
end

