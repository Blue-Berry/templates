{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    janet-lsp-src = {
      url = "github:Blue-Berry/janet-lsp.nix";
      flake = false;
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem = {
        pkgs,
        inputs',
        system,
        ...
      }: let
        janet-lsp = pkgs.callPackage inputs.janet-lsp-src {};
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            janet
            jpm
            janet-lsp
          ];
        };
      };
    };
}
