{ ... }:

{
  # networkmanager + firewall(ssh) come from the shared modules
  networking.hostName = "puppy";
  networking.firewall.allowPing = false;
}