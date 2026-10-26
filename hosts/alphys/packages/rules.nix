{ ... }:

{
  # universal nix gc/settings/autoUpgrade come from lib/partials/nix-common.nix
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-25.05";

  # oh no unfree packages :(
  nixpkgs.config.allowUnfree = false;

  nixpkgs.config.permittedInsecurePackages = [
        "materialgram-7.0.5.1"
        "materialgram-unwrapped-7.0.5.1"
  ];
}
