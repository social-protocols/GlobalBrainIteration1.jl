using GlobalBrain

# 1
# |-2
#   |-4
#   |-5
# |-3
#   |-6
#   |-7

posts = [
  Post(1, nothing),
  Post(2, 1),
  Post(3, 1),
  Post(4, 2),
  Post(5, 2),
  Post(6, 3),
  Post(7, 3),
]

informed_tallies =
  [
    InformedTally(1, nothing, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
    InformedTally(1, 2, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
    InformedTally(1, 3, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
    InformedTally(2, nothing, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
    InformedTally(2, 4, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
    InformedTally(2, 5, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
    InformedTally(3, nothing, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
    InformedTally(3, 6, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
    InformedTally(3, 7, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
    InformedTally(4, nothing, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
    InformedTally(5, nothing, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
    InformedTally(6, nothing, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
    InformedTally(7, nothing, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
  ]

informed_tallies_dict = Dict{Int, Array{InformedTally}}()
for it in informed_tallies
  key = it.post_id
  value = [it for it in informed_tallies if it.post_id == key]
  informed_tallies_dict[it.post_id] = value
end
print(informed_tallies_dict)

post_tally = Tally(0, 0)

top_note_id, p1, p2 = find_top_reply(1, post_tally, informed_tallies_dict)

println("top_note_id: ", top_note_id)
println("p1: ", p1)
println("p2: ", p2)



# Dict(
#   it.post_id => it
#   for it in [
#     InformedTally(1, nothing, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
#     InformedTally(1, 2, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
#     InformedTally(1, 3, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
#     InformedTally(2, nothing, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
#     InformedTally(2, 4, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
#     InformedTally(2, 5, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
#     InformedTally(3, nothing, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
#     InformedTally(3, 6, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
#     InformedTally(3, 7, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
#     InformedTally(4, nothing, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
#     InformedTally(5, nothing, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
#     InformedTally(6, nothing, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
#     InformedTally(7, nothing, Tally(0, 0), Tally(0, 0), Tally(0, 0)),
#   ]
# )
