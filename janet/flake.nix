{
  description = "Description for janet project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    janet2nix.url = "github:alan-strohm/janet2nix";

    janet-lsp-src = {
      url = "github:Blue-Berry/janet-lsp.nix";
      flake = false;
    };

    spork = {
      url = "github:janet-lang/spork";
      flake = false;
    };

    posix-spawn = {
      url = "github:andrewchambers/janet-posix-spawn";
      flake = false;
    };
    sh = {
      url = "github:andrewchambers/janet-sh";
      flake = false;
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        j2nLib = inputs.janet2nix.lib.${system};
        janet-lsp = pkgs.callPackage inputs.janet-lsp-src {};
        inherit (pkgs) mkShell;
        name = "hello";

        spork = j2nLib.mkJanetPackage {
          name = "spork";
          src = inputs.spork;
        };
        posix-spawn = j2nLib.mkJanetPackage {
          name = "posix-spawn";
          src = inputs.posix-spawn;
        };
        sh = j2nLib.mkJanetPackage {
          name = "sh";
          src = inputs.sh;
          withJanetPackages = [posix-spawn];
        };
      in {
        devShells = {
          default = mkShell {
            inputsFrom = [self'.packages.default];
            buildInputs = with pkgs; [
              janet
              jpm
              janet-lsp
            ];
          };
        };

        packages = {
          default = j2nLib.mkJanetPackage {
            inherit name;
            src = ./.;
            withJanetPackages = [
              spork
              sh
              posix-spawn
            ];
          };
        };
      };
    };
}
