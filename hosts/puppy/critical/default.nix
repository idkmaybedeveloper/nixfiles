{ partials, ... }:

{
  imports = [
    ./networking.nix
    ./sops.nix
    ./users.nix
    partials.firewall-ssh
    ./boot.nix
    partials.chrony
  ];
}