{ ... }:

{
  # universal nix daemon settings; per-host rules.nix only keeps the bits that
  # actually differ (autoUpgrade.channel, substituters, allowUnfree)
  nix.settings = {
    auto-optimise-store = true;
    trusted-users = [
      "root"
      "@wheel"
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
  };
}
