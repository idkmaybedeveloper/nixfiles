{
  config,
  lib,
  pkgs,
  ...
}:

let
  extraIp = config.sops.secrets.puppy_extra_ip.path;
in
{
  # networkmanager + firewall(ssh) come from the shared modules
  networking.hostName = "puppy";

  # srvos brings systemd-networkd, which does everything this box needs from
  # networkmanager (dhcp on ens1) without dragging in the whole nm closure.
  # the secondary address still comes from puppy-extra-ip below
  networking.networkmanager.enable = lib.mkForce false;

  # not partials.firewall-ssh: that one pins 22 open, and ssh lives elsewhere now
  networking.firewall.enable = true;
  networking.firewall.allowPing = lib.mkForce false; # srvos opens it for pmtu

  sops.secrets.puppy_extra_ip = { };
  systemd.services.puppy-extra-ip = {
    description = "add the secondary address to ens1";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    # networkd renames/reconfigures ens1 on restart and would drop the address
    partOf = [ "systemd-networkd.service" ];
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
