{ partials, ... }:

{
  imports = [
    ./networking.nix
    partials.firewall-ssh
    partials.boot-grub-sda
    ./users.nix
    partials.chrony
  ];
}
