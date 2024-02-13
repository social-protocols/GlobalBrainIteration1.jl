sync:
  git add src/
  git commit -m "WIP"
  julia --eval "using Pkg; Pkg.add(url=pwd())"

dev:
  julia --eval "using Pkg; Pkg.develop(path=pwd())"

db:
  sqlite3 $VOTE_DATABASE_PATH

format:
  julia --eval "using JuliaFormatter; format(pwd())"

