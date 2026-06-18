{ config, pkgs, ... }:

{
  users.users.lain = {
    home = "/Users/lain";
    shell = pkgs.fish;
  };
  programs.fish.enable = true;
}
