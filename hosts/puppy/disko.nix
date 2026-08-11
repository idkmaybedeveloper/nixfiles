{ ... }:

#wipe+partition with:
#nix run github:nix-community/disko -- --mode disko ./hosts/puppy/disko.nix

{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/sda";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          size = "1M";
          type = "EF02";
        };
        swap = {
          size = "4G";
          content = {
            type = "swap";
            discardPolicy = "both";
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
