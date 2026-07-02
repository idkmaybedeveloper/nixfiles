# `nixfiles/alphys`

nixfiles for my surface laptop 3 (alphys). mostly a copy of the x230 (eva01)
config with the ThinkPad bits (thinkfan) dropped, the linux-surface kernel wired
in via nixos-hardware's `microsoft-surface-common`, and the 512G NVMe laid out
with disko (`disko.nix`).

## first install

```sh
# partition + format the disk (WIPES /dev/nvme0n1)
nix run github:nix-community/disko -- --mode disko ./hosts/alphys/disko.nix
nixos-install --flake .#alphys
```

todo:

- regenerate `hardware-configuration.nix` on the device if the initrd module
  list is off (the committed one is a sane SL3/NVMe guess)
  
## catcatcatcatcatcatcatcatcatcatcatcatcatcatcatcatcatcat

![cat](https://cataas.com/cat)
