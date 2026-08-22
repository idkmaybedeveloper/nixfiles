{ config, pkgs, ... }:

{
  imports = [
    ./critical.nix
    ./users.nix
    ./system.nix
    ./defaults.nix
  ];
}
