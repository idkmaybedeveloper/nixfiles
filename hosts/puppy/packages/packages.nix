{ pkgs, ... }:

{
  # curl, git, htop, jq, tmux and dnsutils already come from srvos.nixosModules.server
  environment.systemPackages = with pkgs; [
    wget
    micro
    btop
    ripgrep
    fd
    tree
    ncdu
    duf
    file
    killall
    util-linux
    pciutils
  ];

  # srvos defaults programs.git.package to gitMinimal, which is the whole point:
  # full git drags perl and friends onto a box that only ever does `git log`
  programs.git.enable = true;
  programs.fish.enable = true;
}
