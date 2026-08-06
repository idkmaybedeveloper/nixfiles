{ partials, ... }:

{
  imports = [
    ./networking.nix
    ./users.nix
    partials.firewall-ssh
    partials.boot-grub-sda
    partials.chrony
  ];
}