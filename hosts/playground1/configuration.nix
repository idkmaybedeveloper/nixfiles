{ config, pkgs, ... }:

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

  time.timeZone = "Europe/Moscow";
  system.stateVersion = "25.05";

  # docker_28 got marked insecure upstream, oci-containers default still points at it
  virtualisation.docker.package = pkgs.docker_29;
}
