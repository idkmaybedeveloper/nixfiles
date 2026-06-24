{ ... }:

{
  /*
    SSH banner displayed before authentication
    По мотивам: https://nixos.wiki/wiki/SSH
  */
  environment.etc."motd.ssh".text = ''
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    +      o     +              o
        +             o     +       +
    o          +
        o  +           +        +
    +        o     o       +        o
    -_-_-_-_-_-_-_,------,      o
    _-_-_-_-_-_-_-|   /\_/\
    -_-_-_-_-_-_-~|__( ^ .^)  +     +
    _-_-_-_-_-_-_-""  ""
    +      o         o   +       o
        +         +
    o      o  _-_-_-_-_-_- hm01.vm.msk01
        o           +
    +      +     o        o      +
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    WARNING:
    Use of company facilities and networks is restricted
    to employees and authorized third parties only.
    Any other use of computing facilities and
    networks is strictly forbidden.
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
  '';

  programs.ssh.extraConfig = ''
    Host macvm
      Port 8822
      IdentityFile /var/lib/hydra/queue-runner/keys/macvm
      ServerAliveInterval 120
      TCPKeepAlive yes
  '';
}
