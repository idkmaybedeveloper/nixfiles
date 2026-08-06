{ partials, ... }:

{
  imports = [
    ./networking.nix
    ./users.nix
    partials.firewall-ssh
    ./boot.nix
    partials.chrony
  ];
}