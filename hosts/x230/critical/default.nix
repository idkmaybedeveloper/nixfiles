{ partials, ... }:

{
  imports = [
    ./networking.nix
    partials.boot-efi
    ./bootloader.nix
    ./users.nix
  ];
}
