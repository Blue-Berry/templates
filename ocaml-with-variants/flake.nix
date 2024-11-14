{
  inputs = {
    opam-nix.url = "github:tweag/opam-nix";
    opam-nix.inputs.opam-repository.follows = "opam-repository";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.follows = "opam-nix/nixpkgs";
    with-extensions.url = "github:janestreet/opam-repository/with-extensions";
    with-extensions.flake = false;
    opam-repository.url = "github:ocaml/opam-repository";
    opam-repository.flake = false;
  };
  outputs =
    {
      self,
      flake-utils,
      opam-nix,
      nixpkgs,
      with-extensions,
      opam-repository,
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        on = opam-nix.lib.${system};
        localPackagesQuery =
          builtins.mapAttrs (_: pkgs.lib.last)
          (on.listRepo (on.makeOpamRepo ./.));
        devPackagesQuery = {
          # You can add "development" packages here. They will get added to the devShell automatically.
          # ocaml-lsp-server = "*";
          ocamlformat = "0.26.2+jst";
          merlin = "5.2.1-502+jst";
          ocaml-lsp-server = "1.19.0+jst";
        };
        query = devPackagesQuery // {
          ## You can force versions of certain packages here, e.g:
          ## - force the ocaml compiler to be taken from opam-repository:
          ocaml-variants = "5.2.0+flambda2";
          ## - or force the compiler to be taken from nixpkgs and be a certain version:
          # ocaml-system = "4.14.0";
          ## - or force ocamlfind to be a certain version:
          # ocamlfind = "1.9.2";
        };
        scope = on.buildOpamProject' {
          repos = [
            opam-repository
            with-extensions
          ];
        } ./. query;
        overlay = final: prev: {
          # You can add overrides here
          init-dune = prev.init-dune.overrideAttrs (oa: {
            nativeBuildInputs = oa.nativeBuildInputs ++ [ pkgs.ocaml-ng.ocamlPackages_4_14.ocaml ];
          });
          init-menhir = prev.init-menhir.overrideAttrs (oa: {
            nativeBuildInputs = oa.nativeBuildInputs ++ [ pkgs.ocaml-ng.ocamlPackages_4_14.ocaml ];
            preBuild = "mkdir -p $out/init_deps/bin; ln -s ${final.init-dune}/init_deps/bin/dune $out/init_deps/bin";
          });
          ocaml-variants = prev.ocaml-variants.overrideAttrs (oa: {
            preBuild = ''
              mkdir -p $out/init_deps/bin
              ln -s ${final.init-menhir}/init_deps/bin/menhir ${final.init-dune}/init_deps/bin/dune $out/init_deps/bin
              export PATH=$PATH:${final.init-menhir}/init_deps/bin:${final.init-dune}/init_deps/bin
              sed -i "s|/usr/bin/env|${pkgs.coreutils}/bin/env|g" Makefile Makefile.* ocaml/Makefile.*
            '';
            nativeBuildInputs = oa.nativeBuildInputs ++ [
              pkgs.autoconf
              pkgs.which
              pkgs.rsync
            ];
          });
          stdio = prev.stdio.overrideAttrs (oa: {
            buildInputs = [ final.base final.sexplib0 ];
          });
          base = prev.base.overrideAttrs (oa: {
            buildInputs = [ final.ocaml_intrinsics_kernel final.sexplib0 ];
          });
        };
        scope' = scope.overrideScope overlay;
        # Packages from devPackagesQuery
        devPackages = builtins.attrValues (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) scope');
        # Packages in this workspace
        packages = pkgs.lib.getAttrs (builtins.attrNames localPackagesQuery) scope';
      in
      {
        legacyPackages = scope';

        inherit packages;

        ## If you want to have a "default" package which will be built with just `nix build`, do this instead of `inherit packages;`:
        # packages = packages // { default = packages.<your default package>; };

        devShells.default = pkgs.mkShell {
          inputsFrom = builtins.attrValues packages;
          buildInputs = devPackages ++ [
            # You can add packages from nixpkgs here
          ];
        };
      }
    );
}
