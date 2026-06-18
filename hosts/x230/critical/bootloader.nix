{ pkgs, ... }:

{
  # systemd-boot/efi comes from lib/partials/boot-efi.nix
  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
