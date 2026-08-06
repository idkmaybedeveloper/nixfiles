{ lib, modulesPath, ... }:

# disko.nix owns the partitioning/fileSystems, SOO this only carries the
# virtualised-guest bits. regenerate with `nixos-generate-config --no-filesystems`
# once the box is actually up if the module list turns out to be wrong
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "virtio_pci"
    "virtio_scsi"
    "virtio_blk"
    "xhci_pci"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}