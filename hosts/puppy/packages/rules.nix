{ ... }:

{
  # universal nix gc/settings/autoUpgrade come from lib/partials/nix-common.nix
  # NOTE: srvos sets nix.channel.enable = false, so this channel is only here for
  # bookkeeping; autoUpgrade has nothing to pull until it points at the flake
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-26.05";

  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "http://shit.cuddles.rs/nixos" # TODO: move to https when fixed
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "shit.cuddles.rs:HQ4GqwV3aPbneoDdl4diqMcRjmusLqtQkETdebH62sk="
    ];
  };

  # oh no unfree packages :(
  nixpkgs.config.allowUnfree = false;

  # angie is flagged insecure in nixpkgs: not a CVE, just "insufficiently
  # maintained". we still serve http with it
  nixpkgs.config.permittedInsecurePackages = [ "angie-1.12.1" ];
}
