{ config, lib, pkgs, ... }:

{
  imports = [
    ../base
  ];

  http.base = {
    enable = true;

    sites."nixvm.wejust.rest" = {
      host = "nixvm.wejust.rest";

      proxy = {
        url = "http://127.0.0.1:9000";
        websockets = true;
        passHostHeader = true;
      };
    };
  };

  environment.etc."hello-http/index.html".text = "I_AM_ALIVE";

  systemd.services.hello-http = {
    description = "hello world on 9000";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "/etc/hello-http";
      ExecStart = "${pkgs.python3}/bin/python -m http.server 9000 --bind 127.0.0.1";
      Restart = "always";
      RestartSec = 2;
    };
  };
}
