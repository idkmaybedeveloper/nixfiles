# `nixfiles/puppy`

the vds is **legacy bios** (seabios + ipxe, no `/sys/firmware/efi`), so its grub
on a 1M bios_grub partition and no ESP at all. systemd-boot installs "fine" there
and then the box just sits at `Booting from Hard Disk...` forever, ask me how i
know lol ¯\_(ツ)_/¯

## first install (nixos-anywhere)

boot the box into anything with ssh as root (rescue mode, a debian image,
whatever) and from m68k:

```sh
nix run .#nixos-anywhere -- --flake .#puppy --build-on remote root@<ip>
```

`--build-on remote` because m68k is aarch64-darwin and cant build an
x86_64-linux closure by itself. 2g of ram is tight for that, so if the build
gets OOM-killed, run the same thing from a linux box and drop the flag:

```sh
nix run .#nixos-anywhere -- --flake .#puppy root@<ip>
```

it !!WIPES!! da disk, so check `device` in `disko.nix` first: its `/dev/sda`,
fix it if the vds hands you `/dev/vda` or an nvme.

## rebuilds after that

```sh
nixos-rebuild switch --flake .#puppy --target-host root@<ip>
```