{ ... }:

{
  # networkmanager + firewall(ssh) come from the shared modules
  networking.hostName = "nixvm";
  networking.hosts."192.168.1.65" = [ "macvm" ];
}
