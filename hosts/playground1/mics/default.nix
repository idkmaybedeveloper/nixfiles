{ config, pkgs, ... }:

{
  imports = [
    ./update-motd/motd.nix
  ];
}

