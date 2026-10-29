{ pkgs, ... }:

{
  boot.loader.limine.secureBoot = {
    enable = true;
    autoGenerateKeys = true;
    autoEnrollKeys = {
      enable = true;
      # surface firmware doesnt expose dbDefault
      extraArgs = [ "--microsoft" ];
    };
  };
  environment.systemPackages = [ pkgs.sbctl ];
  boot.kernelParams = [ "intel_iommu=on" ];
}