# `nixfiles/puppy`

the vds is **legacy bios** (seabios + ipxe, no `/sys/firmware/efi`), so its grub
on a 1M bios_grub partition and no ESP at all. systemd-boot installs "fine" there
and then the box just sits at `Booting from Hard Disk...` forever, ask me how i
know lol ¯\_(ツ)_/¯

## first install (nixos-anywhere)

boot the box into anything with ssh as root (rescue mode, a debian image,
whatever), stage the host key, and from m68k:

```sh
install -d -m 755 /tmp/puppy-extra/etc/ssh
install -m 600 ~/.ssh/puppy_host_ed25519_key /tmp/puppy-extra/etc/ssh/ssh_host_ed25519_key
install -m 644 ~/.ssh/puppy_host_ed25519_key.pub /tmp/puppy-extra/etc/ssh/ssh_host_ed25519_key.pub

nix run .#nixos-anywhere -- \
  --flake .#puppy \
  --extra-files /tmp/puppy-extra \
  root@<ip>
```

forget `--extra-files` and the box comes up with a freshly generated host key,
sops cant decrypt, and lain ends up with no password again (and no sudo, and no
way in except the vnc console)

m68k is aarch64-darwin and cant build an x86_64-linux closure by itself, and
`--build-on remote` doesnt work either: 2g of ram + the kexec installers tmpfs
store means the sops-install-secrets go build gets OOM-killed. build on any 
linux box, push to s3, let puppy pull from the cache:


it !!WIPES!! da disk, so check `device` in `disko.nix` first: its `/dev/sda`,
fix it if the vds hands you `/dev/vda` or an nvme.

## rebuilds after that

```sh
nixos-rebuild switch --flake .#puppy --target-host root@<ip>
```