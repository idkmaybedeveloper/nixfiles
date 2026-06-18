{ ... }:

{
  # networkmanager + firewall(ssh) come from the shared modules
  networking.hostName = "playground1";
  networking.firewall.allowedUDPPorts = [ 41641 ];
  networking.firewall.allowPing = false;

  #NOTE(kroot): required for tailscale exit node
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
}
