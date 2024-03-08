using GlobalBrain
using Test

for file in readdir("test")
    if endswith(file, ".jl") && file != "runtests.jl"
        include("$file")
    end
end
