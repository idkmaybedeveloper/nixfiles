{
  config,
  pkgs,
  cursed-ping,
  ...
}:

let
  cursedPing = cursed-ping.packages.${pkgs.system}.pinger;
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
    duf
    p0f
    sops
    attic-client
  ];

  programs.git.enable = true;
  programs.fish.enable = true;
}
