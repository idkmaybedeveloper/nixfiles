{ config, pkgs, ... }:

{
  home.username = "lain";
  home.homeDirectory = "/Users/lain";
  home.stateVersion = "25.11";

  imports = [
    ./home
    ./packages
    ./editor
  ];
}
