{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./ssh/ssh.nix
    ./critical
    ./packages
  ];

  #zram gives the build some breathing room before it hits the swap partition on disk
  zramSwap.enable = true;

  time.timeZone = "Europe/Moscow";
  system.stateVersion = "25.11";
}