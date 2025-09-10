{
  description = "Description for ocaml project";

  inputs = {
    nixpkgs.url = "github:nix-ocaml/nix-overlays";
    flake-parts.url = "github:hercules-ci/flake-parts";
    opam-nix.url = "github:tweag/opam-nix";
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
        inherit (pkgs) dockerTools mkShell;
        inherit (dockerTools) buildImage;
        inherit (inputs.opam-nix.lib.${system}) buildOpamProject materializedDefsToScope materializeOpamProject';
        query = {
          ocaml-base-compiler = "*";
        };
        # Use specific version of ocamlPackages
        # inherit (pkgs) ocamlPackages;
        ocamlPackages = pkgs.ocaml-ng.ocamlPackages_5_3;
        name = "CahngeMe";
        version = "0.0.1";

       overlay = final: prev: {
          "${name}" = prev.${name}.overrideAttrs (_: {
            # override derivation attributes, e.g. add additional dependacies
            buildInputs = [ ];
          });
        };

        resolved-scope =
          let scope = buildOpamProject { } name ./. query;
          in scope.overrideScope' overlay;
        materialized-scope =
          let scope = materializedDefsToScope
            { sourceMap.${name} = ./.; } ./package-defs.json;
          in scope.overrideScope' overlay;
      in rec {
        devShells = {
          default = mkShell {
            inputsFrom = [self'.packages.default];
            buildInputs = with ocamlPackages; [
              utop
              ocamlformat
              # patch ocaml-lsp so that inlay hints dont hide ghost values
              (ocamlPackages.ocaml-lsp.overrideAttrs (oldAttrs: {
                patches = [
                  ./inlay-hints.patch
                ];
              }))
            ];
          };
        };

        packages = {
          resolved = resolved-scope;
          materialized = materialized-scope;
          package-defs = materializeOpamProject' {} ./. query;
          default = materialized-scope.${name};

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
