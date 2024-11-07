{
  description = "A collection of flake templates";

  outputs = { self }: {

    templates = {

     ocaml = {
        path = ./ocaml;
        description = "Bare Bones Ocaml env";
        welcometext = ''
        Simple Ocaml
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
