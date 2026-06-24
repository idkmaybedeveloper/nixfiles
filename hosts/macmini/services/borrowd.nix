{
  config,
  lib,
  pkgs,
  borrowd,
  ...
}:

with lib;

let
  cfg = config.services.borrowd;
  borrowdPkg = borrowd.packages.${pkgs.system}.default;
in
{
  options.services.borrowd = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "whether to enable the borrowd tcp license server";
    };

    listenAddress = mkOption {
      type = types.str;
      default = "0.0.0.0:65434";
      description = "tcp license server listen address";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/borrowd";
      description = "Directory for state data";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.borrowd = {
      description = "borrowd tcp license server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${borrowdPkg}/bin/borrowd -tcp-listen ${cfg.listenAddress} -data ${cfg.dataDir}/borrowd.json";
        StateDirectory = "borrowd";
        WorkingDirectory = cfg.dataDir;
        Restart = "always";
        DynamicUser = true;
      };
    };
  };
}
