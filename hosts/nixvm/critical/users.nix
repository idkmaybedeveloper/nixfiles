{ pkgs, ... }:

{
  users.users = {
    lain.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGb+mnYg/j9RjNrobslixSX12qGRtwvx+jnYtUElxId1 lain@kaworu"
    ];
    root.shell = "${pkgs.util-linux}/bin/nologin";
  };
}
