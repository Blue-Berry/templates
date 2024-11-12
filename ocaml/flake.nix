{
  description = "Description for ocaml project";

  inputs = {
    nixpkgs.url = "github:nix-ocaml/nix-overlays";
    flake-parts.url = "github:hercules-ci/flake-parts";
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
        serial = ocamlPackages.buildDunePackage rec {
          # https://opam.ocaml.org/packages/serial/
          pname = "serial";
          version = "";
          src = builtins.fetchurl {
            url = "https://github.com/m-laniakea/oserial/releases/download/v0.1.0/serial-0.1.0.tbz";
            sha256 = "sha256:5034e009b14e0ba3a82b48026de13b2df3d80f37e14bd013b5dbd062f698370c";
          };
          propagatedBuildInputs = with pkgs; [
            # Add the packages needed
            ocamlPackages.lwt
          ];
        };
        inherit (pkgs) dockerTools ocamlPackages mkShell;
        inherit (dockerTools) buildImage;
        inherit (ocamlPackages) buildDunePackage;
        name = "CahngeMe";
        version = "0.0.1";
      in {
        devShells = {
          default = mkShell {
            inputsFrom = [self'.packages.default];
            buildInputs = [pkgs.ocamlPackages.utop pkgs.ocamlPackages.ocaml-lsp pkgs.ocamlPackages.ocamlformat pkgs.ocamlPackages.magic-trace];
          };
        };

        packages = {
          default = buildDunePackage {
            inherit version;
            pname = name;
            src = ./.;
            buildInputs = with pkgs.ocamlPackages; [
              serial
              core
              lwt
            ];
          };

          docker = buildImage {
            inherit name;
            tag = version;
            config = {
              Cmd = ["${self'.packages.default}/bin/${name}"];
              Env = [
                "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
              ];
            };
          };
        };
      };
    };
}
