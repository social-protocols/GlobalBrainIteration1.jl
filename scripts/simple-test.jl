using GlobalBrain

post_tally, posts, informed_tallies = create_random_discussion(20, 15)

println("Starting computation...")
estimate = find_top_reply(1, post_tally, informed_tallies)

println("--------------")
println("Informed tallies: ")
for k in sort(collect(keys(informed_tallies)))
  println(k, ": ", informed_tallies[k])
end
println("--------------")
println("top_note_id: ", estimate.note_id)
println("given shown note: ", estimate.p_given_shown_note)
println("given not shown note: ", estimate.p_given_not_shown_note)


# ------------------------------------------------------------------------------
# --- OLD EXAMPLE --------------------------------------------------------------
# ------------------------------------------------------------------------------

# --- Discussion tree:
# 1
# |-2
#   |-4
#   |-5
# |-3
#   |-6
#   |-7

# posts = [
#   Post(1, nothing),
#   Post(2, 1),
#   Post(3, 1),
#   Post(4, 2),
#   Post(5, 2),
#   Post(6, 3),
#   Post(7, 3),
# ]

# informed_tallies = [
#   InformedTally(1, 2, Tally(5, 10), Tally(8, 14), Tally(6, 9)),
#   InformedTally(1, 3, Tally(8, 11), Tally(9, 16), Tally(1, 13)),
#   InformedTally(2, 4, Tally(12, 12), Tally(8, 9), Tally(0, 10)),
#   InformedTally(2, 5, Tally(5, 7), Tally(5, 6), Tally(7, 13)),
#   InformedTally(3, 6, Tally(3, 4), Tally(5, 8), Tally(2, 3)),
#   InformedTally(3, 7, Tally(8, 15), Tally(7, 10), Tally(3, 15)),
# ]

