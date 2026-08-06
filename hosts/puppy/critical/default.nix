{ partials, ... }:

{
  imports = [
    ./networking.nix
    ./users.nix
    partials.firewall-ssh
    partials.boot-efi
    partials.chrony
  ];
}