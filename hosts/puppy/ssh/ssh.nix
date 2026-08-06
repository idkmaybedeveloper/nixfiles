{ ... }:

{
  # openssh-hardening has openFirewall = true, so this opens itself and 22 stays shut
  services.openssh.ports = [ 59093 ];

  environment.etc."motd.ssh".text = ''
    sowwy but not today :p
  '';
}
