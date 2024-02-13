dev:
  julia --eval "using Pkg; Pkg.develop(path=pwd())"

db:
  sqlite3 $VOTE_DATABASE_PATH

format:
  julia --eval "using JuliaFormatter; format(pwd())"

