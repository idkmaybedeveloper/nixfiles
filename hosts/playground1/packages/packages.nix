{ config, pkgs, cursed-ping, attic, ... }:

let
  cursedPing = cursed-ping.packages.${pkgs.system}.pinger;
  atticPkg = attic.packages.${pkgs.system}.attic;
in
{
  environment.systemPackages = with pkgs; [
    micro
    curl
    fastfetch
    htop
    git
    wget
    vim
    tmux
    jq
    ncdu
    tree
    bat
    fd
    ripgrep
    cmatrix
    fish
    btop
    pciutils
    dnsutils
    bridge-utils
    cowsay
    util-linux
    file
    cursedPing
    killall
    duf # im already fucked up writing nix-shell -p duf every time i want to run duf
    p0f
    atticPkg
  ];

  programs.git.enable = true;
  programs.fish.enable = true;
}
