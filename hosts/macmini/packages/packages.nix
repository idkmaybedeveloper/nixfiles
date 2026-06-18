{ config, pkgs, ... }:

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
    fish
    btop
    pciutils
    dnsutils
    bridge-utils
    util-linux
    file
    killall
    python3
    duf
  ];

  programs.git = {
    enable = true;
    config = {
      http.version = "HTTP/1.1";
    };
  };
  programs.fish.enable = true;
}
