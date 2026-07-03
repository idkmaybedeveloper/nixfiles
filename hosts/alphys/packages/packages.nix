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
    bazelisk

    # driftwm deps
    alacritty
    swaylock
    swayidle
    grim
    slurp
    wl-clipboard
    brightnessctl
    playerctl
    polkit_gnome
  ];
}
