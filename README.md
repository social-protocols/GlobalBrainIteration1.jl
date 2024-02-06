# GlobalBrain

*Julia implementation of the [Global Brain algorithm](https://social-protocols.org/global-brain/).*

## Workflow

*This workflow is kind of hacky, so it's temporary. There are clearly better workflows for Julia packages, but I found them a bit annoying at first glance since they are a little opinionated.*

To update your local installation of the package, execute `just sync`.
Apparently the `Pkg` package manager uses commit hashes to determine whether a package is up-to-date, so we need to make a commit to let `Pkg` know that we updated the package.
The `just sync` recipe will create a git commit with the message "WIP" if you changed anything in the `src` code.
It will then `Pkg.add` the package locally, so you can play around with it.
You can later squash the "WIP" commits in one and push them to the remote repository.

