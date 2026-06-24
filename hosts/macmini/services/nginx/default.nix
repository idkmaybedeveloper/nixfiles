{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./forgejo.nix
  ];

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
