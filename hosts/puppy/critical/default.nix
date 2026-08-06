{ partials, ... }:

{
  imports = [
    ./networking.nix
    ./sops.nix
    ./users.nix
    ./boot.nix
    partials.chrony
  ];
}