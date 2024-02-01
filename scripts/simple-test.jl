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

informed_tallies = [
  InformedTally(1, nothing, UpDownTally(0, 0), UpDownTally(0, 0), UpDownTally(0, 0)),
  InformedTally(1, 2, UpDownTally(0, 0), UpDownTally(0, 0), UpDownTally(0, 0)),
  InformedTally(1, 3, UpDownTally(0, 0), UpDownTally(0, 0), UpDownTally(0, 0)),
  InformedTally(2, nothing, UpDownTally(0, 0), UpDownTally(0, 0), UpDownTally(0, 0)),
  InformedTally(2, 4, UpDownTally(0, 0), UpDownTally(0, 0), UpDownTally(0, 0)),
  InformedTally(2, 5, UpDownTally(0, 0), UpDownTally(0, 0), UpDownTally(0, 0)),
  InformedTally(3, nothing, UpDownTally(0, 0), UpDownTally(0, 0), UpDownTally(0, 0)),
  InformedTally(3, 6, UpDownTally(0, 0), UpDownTally(0, 0), UpDownTally(0, 0)),
  InformedTally(3, 7, UpDownTally(0, 0), UpDownTally(0, 0), UpDownTally(0, 0)),
  InformedTally(4, nothing, UpDownTally(0, 0), UpDownTally(0, 0), UpDownTally(0, 0)),
  InformedTally(5, nothing, UpDownTally(0, 0), UpDownTally(0, 0), UpDownTally(0, 0)),
  InformedTally(6, nothing, UpDownTally(0, 0), UpDownTally(0, 0), UpDownTally(0, 0)),
  InformedTally(7, nothing, UpDownTally(0, 0), UpDownTally(0, 0), UpDownTally(0, 0)),
]

post_tally = UpDownTally(0, 0)

top_note_id, p1, p2 = find_top_reply(post_tally, informed_tallies)

println("top_note_id: ", top_note_id)
println("p1: ", p1)
println("p2: ", p2)

