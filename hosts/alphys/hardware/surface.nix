{ pkgs, lib, ... }:

{
  # linux-surface kernel + surface modules (IPTS touch, buttons, dgpu, ...) come
  # from nixos-hardware's microsoft-surface-common, wired in flake.nix.
  services.thermald.enable = true;
  hardware.sensor.iio.enable = lib.mkDefault true;
  hardware.enableRedistributableFirmware = true;
}