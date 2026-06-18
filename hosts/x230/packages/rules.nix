{ ... }:

{
  # universal nix gc/settings/autoUpgrade come from lib/partials/nix-common.nix
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-25.05";

  # oh no unfree packages :(
  nixpkgs.config.allowUnfree = false;
}
