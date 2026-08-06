{ ... }:

{
  # universal nix gc/settings/autoUpgrade come from lib/partials/nix-common.nix
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-25.11";

  nix.settings = {
    substituters = [
      #
    ];
    trusted-public-keys = [
      #TODO: maybe in future i add more substituters
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  # oh no unfree packages :(
  nixpkgs.config.allowUnfree = false;
}