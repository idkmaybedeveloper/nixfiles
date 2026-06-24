{
  config,
  lib,
  pkgs,
  ...
}:

{
  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";

  virtualisation.oci-containers.containers.cobalt = {
    hostname = "cobalt";
    image = "ghcr.io/imputnet/cobalt:staging";
    autoStart = true;
    environment = {
      API_URL = "https://co.wejust.rest/";
      DISABLED_SERVICES = "youtube,ok,rutube,vk";
    };
    ports = [ "127.0.0.1:9000:9000/tcp" ];
    extraOptions = [
      "--init"
      "--read-only"
    ];
  };
}
