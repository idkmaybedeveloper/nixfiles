{ config, lib, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";

  virtualisation.oci-containers.containers.legacymkch = {
    hostname = "legacymkch";
    image = "git.fuckyougoogle.xyz/lain/legacymkch:latest";
    environment = {
      PORT = "8888";
      CONTAINER_NAME = "legacymkch";
    };
    environmentFiles = [
      "/etc/somesecrets/lmkch.env"
    ];
    ports = [ "127.0.0.1:8888:8888/tcp" ];
    volumes = [
      "/etc/somesecrets/lmkch_config.js:/app/config.js:rw"
    ];
  };

  systemd.services.docker-legacymkch.serviceConfig.ExecStartPre = lib.mkForce [
    "-${config.virtualisation.docker.package}/bin/docker rm -f legacymkch"
  ];
}