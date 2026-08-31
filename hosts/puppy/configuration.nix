{ lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disko.nix
    ./ssh/ssh.nix
    ./critical
    ./packages
    ./services
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  networking.useDHCP = lib.mkDefault true;

  #zram gives the build some breathing room before it hits the swap partition on disk
  zramSwap.enable = true;

  # journald mmaps the whole journal, so on a 2g box the cap is a memory knob as
  # much as a disk one. the default is 10% of /, ie ~2g here
  services.journald.extraConfig = ''
    SystemMaxUse=128M
    RuntimeMaxUse=16M
  '';

  # -m mlockall()s chrony, which pins ~50m resident for a daemon that otherwise
  # needs single digits. nts stays, we just let the pages be swappable
  services.chrony.enableMemoryLocking = false;

  time.timeZone = "Europe/Moscow";
  system.stateVersion = "25.11";
}
