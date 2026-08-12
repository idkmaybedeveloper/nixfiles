{ partials, ... }:

{
  imports = [
    ./networking.nix
    partials.boot-limine
    ./bootloader.nix
    ./users.nix
  ];
}
