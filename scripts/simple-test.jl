using GlobalBrain

# --- Discussion tree:
# 1
# |-2
#   |-4
#   |-5
# |-3
#   |-6
#     |-7
# posts = [
#   Post(1, nothing, 0),
#   Post(2, 1, 0),
#   Post(3, 1, 0),
#   Post(4, 2, 0),
#   Post(5, 2, 0),
#   Post(6, 3, 0),
#   Post(7, 6, 0),
# ]

# informed_tallies_vec = [
#   DetailedTally(1, 2, BernoulliTally(5, 10), BernoulliTally(8, 14), BernoulliTally(6, 9)),
#   DetailedTally(1, 3, BernoulliTally(8, 11), BernoulliTally(9, 16), BernoulliTally(1, 13)),
#   DetailedTally(2, 4, BernoulliTally(12, 12), BernoulliTally(8, 9), BernoulliTally(0, 10)),
#   DetailedTally(2, 5, BernoulliTally(5, 7), BernoulliTally(5, 6), BernoulliTally(7, 13)),
#   DetailedTally(3, 6, BernoulliTally(3, 4), BernoulliTally(5, 8), BernoulliTally(2, 3)),
#   DetailedTally(6, 7, BernoulliTally(8, 15), BernoulliTally(7, 10), BernoulliTally(3, 15)),
# ]

# informed_tallies = Dict(p.id => DetailedTally[] for p in posts)
# for it in informed_tallies_vec
#   if haskey(informed_tallies, it.post_id)
#     push!(informed_tallies[it.post_id], it)
#   end
# end

# println("--------------")
# println("Informed tallies: ")
# for k in sort(collect(keys(informed_tallies)))
#   println(k, ":")
#   for it in informed_tallies[k]
#     println(it)
#   end
# end

tallies = get_detailed_tallies(db, nothing, nothing)

write_to_db = (score_data) -> begin
	for s in score_data  
		insert_score_data(db, s, snapshot_timestamp)
	end
end

println("--------------")
println("Starting computation...")
estimate = score_posts(informed_tallies, write_to_db)

println("--------------")
println("Results: ")
for e in estimate
  println(e)
end

# println("==============")

# top_reply = find_top_reply(1, informed_tallies)

# println("--------------")
# println("Top reply: ")
# println(top_reply)

