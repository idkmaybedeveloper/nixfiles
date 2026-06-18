{ ... }:

{
  # shared by every sops-using host (the sops-nix module itself is wired per-host
  # in flake.nix). secrets + defaultSopsFile stay host-local.
  sops.age.sshKeyPaths = [ "/home/lain/.ssh/agenix_key" ];
}
