
{
  description = "Description for ocaml project";

  inputs = {
    nixpkgs.url = "/home/liam/playground/ocaml/nix-overlays";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        inherit (pkgs) dockerTools mkShell;
        ocamlPackages = pkgs.ocaml-ng.ocamlPackages_flambda2;
        inherit (ocamlPackages) buildDunePackage;
        name = "CahngeMe";
        version = "0.0.1";
      in {
        devShells = {
          default = mkShell {
            inputsFrom = [self'.packages.default];
            buildInputs = [];
          };
        };

        packages = {
          default = buildDunePackage {
            inherit version;
            pname = name;
            src = ./.;
            buildInputs = with pkgs.ocamlPackages; [
            ];
          };
        };
      };
    };
}

