{ config, lib, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";

  virtualisation.oci-containers.containers.nickel = {
    hostname = "nickel";
    image = "ghcr.io/idkmaybedeveloper/nickel:f38ced8";
    ports = [ "127.0.0.1:8993:8080/tcp" ];
  };
}
