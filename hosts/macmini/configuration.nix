{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./ssh/ssh.nix
    ./packages
    ./critical
    ./mics
    ./security
    ./services
  ];

  system.stateVersion = "26.05";
}
