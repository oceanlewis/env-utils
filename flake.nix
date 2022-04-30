{
  description = ''
    A small set of Nix utility functions to allow for reading env files and interpolating them into `mkShell`'s `shellHook`.
  '';

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-unstable;
  };

  outputs = { self, nixpkgs }: {
    lib = import ./.;

    devShell = {
      aarch64-darwin = import ./nix/shell.nix {
        pkgs = import nixpkgs { system = "aarch64-darwin"; };
      };
      x86_64-darwin = import ./nix/shell.nix {
        pkgs = import nixpkgs { system = "x86_64-darwin"; };
      };
    };
  };
}
