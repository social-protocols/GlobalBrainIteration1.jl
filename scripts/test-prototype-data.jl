using GlobalBrain
# include("scripts/distributions.jl")

# 

# --- Discussion tree:
# 1
# |-2
#   |-4
#   |-5
# |-3
#   |-6
#     |-7
posts = [
  Post(1, nothing, 0),
  Post(2, 1, 0),
  Post(3, 1, 0),
  Post(4, 2, 0),
  Post(5, 2, 0),
  Post(6, 3, 0),
  Post(7, 6, 0),
]


const t = BernoulliTally

test_trees = [ 
	InMemoryTree(DetailedTally(707, nothing, 1, t(0, 0), t(0, 0), t(0, 0), t(20, 30)), [
    InMemoryTree(DetailedTally(707, 1, 2, t(6, 16), t(8, 14), t(6, 9), t(7, 14)), [        
        InMemoryTree(DetailedTally(707, 2, 4, t(7, 14), t(8, 9), t(0, 10), t(12, 12)),[])
        InMemoryTree(DetailedTally(707, 2, 5, t(7, 14), t(5, 6), t(7, 13), t(5, 7)),[])
    ]),
    InMemoryTree(DetailedTally(707, 1, 3, t(6, 16), t(9, 16), t(1, 13), t(8, 11)), [
        InMemoryTree(DetailedTally(707, 3, 6, t(4, 8), t(5, 8), t(2, 3), t(3, 4)), [
           InMemoryTree(DetailedTally(707, 6, 7, t(4, 18), t(7, 10), t(3, 15), t(8, 15)),[])
        ])
    ])
  ])
];


function print_results(results::Vector{ScoreData})
	for r in results
		println("Got result: ", r)
	end
end

# informed_tallies_generator = Base.Generator(identity, informed_tallies_vec)
scores = score_posts(test_trees, print_results)

db = get_score_db()


tallies = get_detailed_tallies(db, nothing, nothing)

snapshot_timestamp = 1234

write_to_db = (score_data) -> begin
	for s in score_data  
		insert_score_data(db, s, snapshot_timestamp)
	end
end


# Connect to the SQLite database

scores = score_posts(tallies, write_to_db)

close(db)

# score_posts(tallies)



