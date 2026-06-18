{ config, pkgs, ... }:

{
  # IMPORTANT:
  # nix-daemon is managed by Determinate
  # DO NOT enable nix.enable
  nix.enable = false;

  nix.settings = {
    cores = 8;
    max-jobs = 8;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://cache.wejust.rest/labs"
    ];
    trusted-public-keys = [
      "labs:1+w3w/rjRYzPhQals2BIspD0DZSyNmCP+dD76gGQPGU="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    netrc-file = "/Users/lain/.config/nix/netrc";
    trusted-users = [
      "root"
      "lain"
      "@admin"
    ];
    builders-use-substitutes = true;
  };

  #nix.extraOptions = ''
  #  builders = ssh-ng://lain@playground1 x86_64-linux - 16 1
  #  builders = ssh-ng://lain@playground2 x86_64-linux - 32 1
  #'';

  system.primaryUser = "lain";
  networking.hostName = "m68k";
  system.stateVersion = 4;
}
