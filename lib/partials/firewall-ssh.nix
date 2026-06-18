{ ... }:

{
  # default firewall posture for the servers: only ssh in
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
}
