{ ... }:

# 512G NVMe on the surface laptop 3, unencrypted btrfs with subvolumes.
# disko owns fileSystems/swap, so hardware-configuration.nix keeps only the
# kernel-module bits. wipe+partition with:
# nix run github:nix-community/disko -- --mode disko ./hosts/alphys/disko.nix
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [
              "fmask=0077"
              "dmask=0077"
            ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            subvolumes = {
              "/@" = {
                mountpoint = "/";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
              };
              "/@home" = {
                mountpoint = "/home";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
              };
              "/@nix" = {
                mountpoint = "/nix";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
              };
              "/@swap" = {
                mountpoint = "/swap";
                swap.swapfile.size = "16G";
              };
            };
          };
        };
      };
    };
  };
}
