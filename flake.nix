{
  description = "A collection of flake templates";

  outputs = {self}: {
    templates = {
      ocaml = {
        path = ./ocaml;
        description = "Bare Bones Ocaml env";
        welcometext = ''
          Simple Ocaml
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
