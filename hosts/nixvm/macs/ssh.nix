{ config, pkgs, ... }:

let
  nixStoreServeCmd = "NIX_SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt ${config.nix.package}/bin/nix-store --serve --store daemon --write";
  authorizedBuildKey = key: "command=\"${nixStoreServeCmd}\" ${key}";
  hydraQueueRunnerKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGn/cjZyaXumh3HanSh5W8vJjFVjZ8XEMkwkHVJq4gSG hydra-queue-runner@macvm";
in

{
  users.users.root.openssh.authorizedKeys.keys = [
    (authorizedBuildKey hydraQueueRunnerKey)
  ];
}
