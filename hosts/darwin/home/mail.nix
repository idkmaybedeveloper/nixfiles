{ config, pkgs, ... }:

{
  accounts.email.accounts.lain = {
    primary = true;
    address = "lain@iwakura.page";
    realName = "Lain Iwakura";
    userName = "lain@iwakura.page";

    imap = {
      host = "mail.iwakura.page";
      port = 993;
      tls.enable = true;
    };

    smtp = {
      host = "mail.iwakura.page";
      port = 587;
      tls = {
        enable = true;
        useStartTls = true;
      };
    };

    thunderbird.enable = true;
  };

  programs.thunderbird = {
    enable = true;
    package = pkgs.thunderbird;
    profiles.lain.isDefault = true;
  };
}
