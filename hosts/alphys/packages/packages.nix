{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [ ./skid.nix ];
  nixpkgs.overlays = [ inputs.helium-linux.overlays.default ];
  programs.fish.enable = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    fish
    git
    micro
    duf
    fastfetch
    materialgram
    adwaita-icon-theme
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.blur-my-shell
    nixos-artwork.wallpapers.nineish-catppuccin-mocha
    btop
    htop
    gitoxide
    sops
    q
    dig
    whois
    blackbox-terminal
    ripgrep
    bat
    kubectl
    go
    gcc
    clang
    gelly
    tailscale
    file
    helium
    tea
  ];
}
