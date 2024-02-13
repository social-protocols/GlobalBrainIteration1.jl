using GlobalBrain

db = get_score_db()

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

