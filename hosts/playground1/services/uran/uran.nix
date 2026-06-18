{ config, lib, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";

  virtualisation.oci-containers.containers.uran = {
    hostname = "uran";
    image = "ghcr.io/idkmaybedeveloper/uran:391e26e";
    ports = [ "127.0.0.1:8994:8080/tcp" ];
  };
}
