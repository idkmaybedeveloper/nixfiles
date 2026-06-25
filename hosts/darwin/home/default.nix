{ config, pkgs, ... }:

{
  imports = [
    ./shell.nix
    ./git.nix
    ./vi.nix
    #./mail.nix NOTE: https://hydra.nixos.org/build/332347770 KILL YOUSELF
  ];
}
