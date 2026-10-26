{ pkgs, lib, ... }:

{
  # linux-surface kernel + surface modules (IPTS touch, buttons, dgpu, ...) come
  # from nixos-hardware's microsoft-surface-common, wired in flake.nix.
  # SL3 panel comes back from dpms off blinking once and dying again; psr is the
  # usual suspect on icelake-era i915. drop this line if it turns out innocent.
  boot.kernelParams = [ "i915.enable_psr=0" ];

  #FIXME: drop once nixos-hardware bumps the surface kernel past 6.19.8.
  #ref: https://github.com/torvalds/linux/commit/905b06d32a52
  boot.kernelPatches = [
    {
      name = "rust-1.98-target-spec";
      patch = pkgs.fetchurl {
        url = "https://github.com/torvalds/linux/commit/905b06d32a52.patch";
        hash = "sha256-HoCjPlgF7ZxY0W4a4dfyUmpJMHF+p5US1gLKKPUgjhM=";
      };
    }
  ];

  services.thermald.enable = true;
  hardware.sensor.iio.enable = lib.mkDefault true;
  hardware.enableRedistributableFirmware = true;
}
