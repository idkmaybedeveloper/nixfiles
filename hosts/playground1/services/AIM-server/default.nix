{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.aim-oscar-server;
  aimPkg = pkgs.buildGo126Module {
    pname = "open-oscar-server";
    version = "unstable";
    src = pkgs.fetchFromGitHub {
      owner = "mk6i";
      repo = "open-oscar-server";
      # Pin upstream to keep the fixed-output fetch reproducible.
      rev = "9e2b640b3e9751b291e89061c6359910a3c38376";
      sha256 = "sha256-SXpDEbnKRzS3aZm0H/h+VWgFCl5f/syw8yglbPPAbL0=";
    };
    vendorHash = "sha256-+7qeNjuCfSkA1mPU4sx8PqytKWO0o8vbLfvmg2C0so8=";
    subPackages = [ "./cmd/server" ];
    env.CGO_ENABLED = "0";
    meta.mainProgram = "server";
  };
in
{
  options.services.aim-oscar-server = {
    enable = lib.mkEnableOption "Enable AIM OSCAR server";

    configPath = lib.mkOption {
      type = lib.types.path;
      default = "/etc/open-oscar-server/settings.env";
      description = "Path to server config .env file";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Extra env vars";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ aimPkg ];

    networking.firewall.allowedTCPPorts = [
      5190
      9898
    ];

    users.groups.aimoscar = { };
    users.users.aimoscar = {
      isSystemUser = true;
      group = "aimoscar";
      home = "/var/lib/aim-oscar-server";
      createHome = true;
    };

    systemd.services.aim-oscar-server = {
      description = "AIM OSCAR Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        User = "aimoscar";
        Group = "aimoscar";
        Restart = "on-failure";
        RestartSec = 3;
        DynamicUser = false;
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        NoNewPrivileges = true;
        WorkingDirectory = "/var/lib/aim-oscar-server";
        StateDirectory = "aim-oscar-server";
        ExecStart = ''
          ${lib.getExe aimPkg} -config ${cfg.configPath}
        '';
      };

      environment = cfg.environment;
    };
  };
}
