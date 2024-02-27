dev:
  julia --eval "using Pkg; Pkg.develop(path=pwd())"

db:
  sqlite3 $VOTE_DATABASE_PATH

test:
  julia --project test/runtests.jl

format:
  julia --eval "using JuliaFormatter; format(joinpath(pwd(), \"src\"))"

