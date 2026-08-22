{ ... }:

{
  # universal nix gc/settings/autoUpgrade come from lib/partials/nix-common.nix
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-25.11";

  nix.settings = {
    substituters = [
      "https://cache.wejust.rest/labs"
    ];
    trusted-public-keys = [
      "labs:1+w3w/rjRYzPhQals2BIspD0DZSyNmCP+dD76gGQPGU="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  # NOTE: permittedInsecurePackages for angie lives in flake.nix, this host gets
  # its pkgs from mkPkgs so nixpkgs.config here would trip the nixpkgs assertion
}
