{
  config,
  pkgs,
  nix-minecraft,
  partials,
  abs,
  ...
}:

{
  nixpkgs.overlays = [
    nix-minecraft.overlays.default
  ];

  imports = [
    ./hardware-configuration.nix
    ./ssh/ssh.nix
    ./packages
    ./critical
    ./mics
    ./security
    ./services
    partials.sops-base
    nix-minecraft.nixosModules.minecraft-servers
  ];

  time.timeZone = "Europe/Moscow";
  system.stateVersion = "25.05";
  sops.defaultSopsFile = abs "secrets/playground2.yaml";

  sops.secrets.velocity_secret = {
    sopsFile = abs "secrets/playground2.yaml";
    key = "velocity_secret";
  };
}
