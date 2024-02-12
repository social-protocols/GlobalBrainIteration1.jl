
# include("scripts/distributions.jl")
include("src/probabilities.jl")
include("src/types.jl")
include("src/binary-entropy.jl")
include("src/tallies.jl")
include("src/constants.jl")
include("src/algorithm.jl")

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

# post_tally = BernoulliTally(26, 51)

# informed_tallies_vec = [
#   # Depth-first traversal order, starting with root
#   DetailedTally(nothing, 1, BernoulliTally(20, 30), BernoulliTally(0, 0), BernoulliTally(0, 0)),
#   DetailedTally(1, 2, BernoulliTally(5, 10), BernoulliTally(8, 14), BernoulliTally(6, 9)),
#   DetailedTally(2, 4, BernoulliTally(12, 12), BernoulliTally(8, 9), BernoulliTally(0, 10)),
#   DetailedTally(2, 5, BernoulliTally(5, 7), BernoulliTally(5, 6), BernoulliTally(7, 13)),
#   DetailedTally(1, 3, BernoulliTally(8, 11), BernoulliTally(9, 16), BernoulliTally(1, 13)),
#   DetailedTally(3, 6, BernoulliTally(3, 4), BernoulliTally(5, 8), BernoulliTally(2, 3)),
#   DetailedTally(6, 7, BernoulliTally(8, 15), BernoulliTally(7, 10), BernoulliTally(3, 15)),
# ]


struct TestTree <: TalliesTree
  tally::DetailedTally
  children::Vector{TalliesTree}
end


# Implement `children` and `tally` to make DetailedTally implement the (theoretical) TalliesTree interface

function children(t::TestTree) 
	return t.children
end

function tally(t::TestTree)
	return t.tally
end


test_trees = [ 
	TestTree(DetailedTally(707, nothing, 1, BernoulliTally(20, 30), BernoulliTally(0, 0), BernoulliTally(0, 0)), [
    TestTree(DetailedTally(707, 1, 2, BernoulliTally(5, 10), BernoulliTally(8, 14), BernoulliTally(6, 9)), [        
        TestTree(DetailedTally(707, 2, 4, BernoulliTally(12, 12), BernoulliTally(8, 9), BernoulliTally(0, 10)),[])
        TestTree(DetailedTally(707, 2, 5, BernoulliTally(5, 7), BernoulliTally(5, 6), BernoulliTally(7, 13)),[])
    ]),
    TestTree(DetailedTally(707, 1, 3, BernoulliTally(8, 11), BernoulliTally(9, 16), BernoulliTally(1, 13)), [
        TestTree(DetailedTally(707, 3, 6, BernoulliTally(3, 4), BernoulliTally(5, 8), BernoulliTally(2, 3)), [
           TestTree(DetailedTally(707, 6, 7, BernoulliTally(8, 15), BernoulliTally(7, 10), BernoulliTally(3, 15)),[])
        ])
    ])
  ])
];




# informed_tallies_generator = Base.Generator(identity, informed_tallies_vec)
include("src/algorithm.jl")
estimate = score_posts(test_trees)

include("scripts/tallies.jl")
tallies = getDetailedTallies(3, nothing)
estimate = score_posts(tallies)

# score_posts(tallies)



