
{ config, pkgs, lib, ... }:


{
  # Install firefox.
  imports = [ ./skid.nix ];
  programs.fish.enable = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
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
  go
  gcc
  clang
  supersonic
  thinkfan
  tailscale
  file
  kdePackages.falkon
  tea
  ];
}
