{ lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disko.nix
    ./ssh/ssh.nix
    ./critical
    ./packages
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  networking.useDHCP = lib.mkDefault true;

  #zram gives the build some breathing room before it hits the swap partition on disk
  zramSwap.enable = true;

  time.timeZone = "Europe/Moscow";
  system.stateVersion = "25.11";
}
