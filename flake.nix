{
  description = "A collection of flake templates";

  outputs = {self}: {
    templates = {
      janet = {
        path = ./janet;
        description = "Minimal Janet dev shell with janet-lsp (flake-parts)";
        welcometext = ''
          Provides a flake-parts devShell with `janet`, `jpm`, and `janet-lsp` from Blue-Berry/janet-lsp.nix.
        '';
      };
      ocaml = {
        path = ./ocaml;
        description = "Bare Bones Ocaml env";
        welcometext = ''
          Simple Ocaml
        '';
      };
      ocaml-flambda2 = {
        path = ./ocaml-flambda2;
        description = "Bare Bones Ocaml env using the flambda2 compiler";
        welcometext = ''
          Flambda2
        '';
      };
      ocaml-with-variants = {
        path = ./ocaml-with-variants;
        description = "Jane street Ocaml compiler";
        welcometext = ''
          Jane street Ocaml compiler and repo
        '';
      };

      trivial = {
        path = ./trivial;
        description = "A very basic flake";
      };
    };

    defaultTemplate = self.templates.trivial;
  };
}
