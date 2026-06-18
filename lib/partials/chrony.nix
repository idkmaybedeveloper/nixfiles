{ ... }:

{
  time.hardwareClockInLocalTime = false;
  time.timeZone = "Europe/Moscow";

  services.timesyncd.enable = false;

  services.chrony = {
    enable = true;
    servers = [ ]; # disable plain
    extraConfig = ''
      server time.cloudflare.com iburst nts
      server ntppool1.time.nl iburst nts
      server nts.netnod.se iburst nts
      makestep 1.0 3
    '';
  };
}
