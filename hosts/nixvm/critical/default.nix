{ partials, ... }:

{
  imports = [
    ./networking.nix
    partials.firewall-ssh
    ./users.nix
    partials.boot-efi
    ./nix.nix
  ];
}
