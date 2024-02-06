sync:
  git add src/
  git commit -m "WIP"
  julia --eval "using Pkg; Pkg.add(url=pwd())"

