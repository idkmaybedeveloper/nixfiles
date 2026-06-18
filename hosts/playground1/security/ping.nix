{ config, pkgs, cursed-ping, ... }:

let
  cursedPing = cursed-ping.packages.${pkgs.system}.pinger;
in
{
  systemd.services.cursed-ping = {
    description = "Cursed Ping XDP Service";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${cursedPing}/bin/cursed-ping ens1";
      User = "root";
    };
  };
  systemd.services.cursed-ping-lo = {
    description = "Cursed Ping XDP Service";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${cursedPing}/bin/cursed-ping lo";
      User = "root";
    };
  };
}
