{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [ ./skid.nix ];
  nixpkgs.overlays = [
    inputs.helium-linux.overlays.default

    /*
      catppuccin mocha/blue for the whole plasma stack, pinned in one place so
      the system profile (below), sddm (services/desktop.nix) and the plasma
      config (home.nix, via useGlobalPkgs) all point at the same builds.
      upstream: https://github.com/catppuccin/kde
    */
    (final: prev: {
      catppuccinAlphys = {
        kde = prev.catppuccin-kde.override {
          flavour = [ "mocha" ];
          accents = [ "blue" ];
          winDecStyles = [ "modern" ];
        };
        gtk = prev.catppuccin-gtk.override {
          variant = "mocha";
          accents = [ "blue" ];
        };
        papirusFolders = prev.catppuccin-papirus-folders.override {
          flavor = "mocha";
          accent = "blue";
        };
        cursors = prev.catppuccin-cursors.mochaBlue;
        sddm = prev.catppuccin-sddm.override {
          flavor = "mocha";
          accent = "blue";
          font = "Noto Sans";
          background = "${(import ../../../lib/wallpapers { pkgs = final; }).meowmeow}";
        };
      };
    })
  ];
  programs.fish.enable = true;

  # nerd font for terminal/icon glyphs + a proper sans/mono fallback
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

    jq
    wl-clipboard

    # plasma theming (screenshots/lock/idle/polkit all come with plasma6)
    catppuccinAlphys.kde
    catppuccinAlphys.gtk
    catppuccinAlphys.papirusFolders
    catppuccinAlphys.cursors
    ###########

    python3
    uv
  ];
}
