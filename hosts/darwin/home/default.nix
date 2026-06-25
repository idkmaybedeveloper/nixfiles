{ config, pkgs, ... }:

{
  imports = [
    ./shell.nix
    ./git.nix
    ./vi.nix
    ./mail.nix
  ];
}
