{ pkgs, lib, ... }:

{
  # linux-surface kernel + surface modules (IPTS touch, buttons, dgpu, ...) come
  # from nixos-hardware's microsoft-surface-common, wired in flake.nix.
  # SL3 panel comes back from dpms off blinking once and dying again; psr is the
  # usual suspect on icelake-era i915. drop this line if it turns out innocent.
  boot.kernelParams = [ "i915.enable_psr=0" ];

  services.thermald.enable = true;
  hardware.sensor.iio.enable = lib.mkDefault true;
  hardware.enableRedistributableFirmware = true;
}
