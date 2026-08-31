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
  # networkmanager without dragging in the whole nm closure. ens1 is described
  # below, and the sops-held secondary address is fed into the same .network
  networking.networkmanager.enable = lib.mkForce false;

  # not partials.firewall-ssh: that one pins 22 open, and ssh lives elsewhere now
  networking.firewall.enable = true;
  networking.firewall.allowPing = lib.mkForce false; # srvos opens it for pmtu

  sops.secrets.puppy_extra_ip = { };

  systemd.network.networks."10-ens1" = {
    matchConfig.Name = "ens1";
    networkConfig.DHCP = "ipv4";
    linkConfig.RequiredForOnline = "routable";
  };

  systemd.services.puppy-extra-ip = {
    description = "hand the sops-held secondary address to networkd";
    after = [ "systemd-networkd.service" ];
    wants = [ "systemd-networkd.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;

      ExecStart = pkgs.writeShellScript "puppy-extra-ip-up" ''
        set -eu
        dir=/run/systemd/network/10-ens1.network.d
        ${pkgs.coreutils}/bin/mkdir -p "$dir"
        umask 022
        printf '[Network]\nAddress=%s\n' "$(cat ${extraIp})" > "$dir/50-extra-address.conf"
        exec ${pkgs.systemd}/bin/networkctl reload
      '';
    };
  };

  # belt and braces: even if something does delete the primary address, the
  # dhcp one gets promoted instead of being dropped with it
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.promote_secondaries" = 1;
    "net.ipv4.conf.default.promote_secondaries" = 1;
  };
}
