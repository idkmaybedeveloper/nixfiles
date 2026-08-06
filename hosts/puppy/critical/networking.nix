{ config, pkgs, ... }:

let
  extraIp = config.sops.secrets.puppy_extra_ip.path;
in
{
  # networkmanager + firewall(ssh) come from the shared modules
  networking.hostName = "puppy";
  networking.firewall.allowPing = false;

  sops.secrets.puppy_extra_ip = { };
  systemd.services.puppy-extra-ip = {
    description = "add the secondary address to ens1";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;

      ExecStart = pkgs.writeShellScript "puppy-extra-ip-up" ''
        exec ${pkgs.iproute2}/bin/ip address replace "$(cat ${extraIp})" dev ens1
      '';

      ExecStop = pkgs.writeShellScript "puppy-extra-ip-down" ''
        ${pkgs.iproute2}/bin/ip address del "$(cat ${extraIp})" dev ens1 || true
      '';
    };
  };
}