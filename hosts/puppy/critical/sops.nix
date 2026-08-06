{ abs, ... }:

{
  sops.defaultSopsFile = abs "secrets/puppy.yaml";
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets.lain_password = {
    neededForUsers = true;
  };
}