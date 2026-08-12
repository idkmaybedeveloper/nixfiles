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

  # nerd font for waybar/fuzzel icon glyphs + a proper sans/mono fallback
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    iosevka-bin
    noto-fonts
    noto-fonts-color-emoji
  ];
  fonts.fontconfig.defaultFonts = {
    monospace = [ "JetBrainsMono Nerd Font" ];
    sansSerif = [ "Noto Sans" ];
    emoji = [ "Noto Color Emoji" ];
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gnupg
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
    obs-studio

    # niri session deps
    swaylock
    swayidle
    swaybg
    xwayland-satellite
    grim
    slurp
    wl-clipboard
    brightnessctl
    playerctl
    polkit_gnome
    ###########

    python3
    uv
  ];
}
