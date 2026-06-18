{ ... }:

{
  # networkmanager + firewall(ssh) come from the shared modules
  networking.hostName = "playground2";
  networking.firewall.allowPing = false;
}
