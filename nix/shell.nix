{ pkgs }:

with pkgs; let

  buildInputs = [
    entr
    fd
    gnumake
    nushell
  ];

in
mkShell {
  inherit buildInputs;
}
