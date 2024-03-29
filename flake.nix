{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # for `flake-utils.lib.eachSystem`
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ ];
          config.allowUnfree = false;
        };
      in
      {
        devShells = {
          default = with pkgs; pkgs.mkShellNoCC {
            buildInputs = [
              openssh
              just
              git
              less
              julia-bin
              sqlite-interactive
              fzf 
              vim
              neovim
            ];
          };
        };
      }
    );
}

