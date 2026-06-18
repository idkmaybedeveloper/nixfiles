{ config, pkgs, ... }:

let
  envFile = "/run/minecraft-env";
in
{
  systemd.services.minecraft-env = {
    description = "Create Minecraft environment file from sops secrets";
    wantedBy = [ "multi-user.target" ];
    before = [ "minecraft-server-paper.service" "minecraft-server-velocity.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p $(dirname ${envFile})
      echo "velocity_secret=$(cat ${config.sops.secrets.velocity_secret.path})" > ${envFile}
    '';
  };

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    environmentFile = envFile;
  };
}