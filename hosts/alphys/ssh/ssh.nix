{ ... }:

{
  # laptop: sshd off (hardening base comes from nixos-common)
  services.openssh.enable = false;
  services.openssh.settings.Banner = "none";
}