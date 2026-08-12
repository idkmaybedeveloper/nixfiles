{ ... }:

{
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.limine = {
    enable = true;
    efiSupport = true;
  };
}
