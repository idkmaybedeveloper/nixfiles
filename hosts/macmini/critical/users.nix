{ pkgs, ... }:

{
  users.users = {
    lain.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHYUbTj0imU1ov3o+bL7JRcxMBrWqynncCMEdouvht16 platon@Moofbook.local"
    ];
    root.shell = "${pkgs.util-linux}/bin/nologin";
  };
}
