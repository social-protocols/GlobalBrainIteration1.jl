


struct TalliesTree
    children::Function
    tally::Function
end

function children(t::TalliesTree)
    return t.children()
end

function tally(t::TalliesTree)
    return t.tally()
end


struct MemTalliesTree
    children::Vector{String}
    tally::Integer
end

function asTalliesTree(t::MemTalliesTree)
    return TalliesTree(
        () -> t.children,
        () -> t.tally,
    )
end

myVal = MemTalliesTree(["child1", "child2"], 3)

myT = asTalliesTree(myVal)

children(myT)
tally(myT)

