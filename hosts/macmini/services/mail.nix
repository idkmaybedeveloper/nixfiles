{ config, pkgs, ... }:

{
  mailserver = {
    enable = true;
    stateVersion = 3;
    fqdn = "mail.iwakura.page";
    domains = [ "iwakura.page" ];

    accounts = {
      "lain@iwakura.page" = {
        hashedPasswordFile = "/etc/mail/passwd/lain-iwakura";
        aliases = [ "@iwakura.page" ];
      };
    };

    x509.useACMEHost = "mail.iwakura.page";

    enableImap = true;
    enableSubmission = true;

    virusScanning = false;
  };

  networking.firewall.allowedTCPPorts = [
    25
    465
    587
    993
    143
  ];
}
