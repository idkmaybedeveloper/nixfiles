{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    curl
    wget
    git
    vim
    micro
    tmux
    htop
    btop
    fastfetch
    ripgrep
    fd
    jq
    tree
    ncdu
    duf
    file
    killall
    util-linux
    pciutils
    dnsutils
  ];

  programs.git.enable = true;
  programs.fish.enable = true;
}
