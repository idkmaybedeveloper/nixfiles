{ config, pkgs, lib, ... }:

let
  catppuccinSkin = pkgs.fetchFromGitHub {
    owner = "Armanoide";
    repo = "roundcube_catppuccin";
    rev = "7add9e0ddf4da94c512ff4df05e2dd967ad6fce9";
    hash = "sha256-4fHRbYwz+Ty8871c7OAFSIlUS9pFdEf2Q1ql2OiB234=";
  };

  roundcubeWithSkin = pkgs.runCommand "roundcube-with-catppuccin" {} ''
    cp -rT ${pkgs.roundcube} $out
    chmod -R u+w $out
    cp -rT ${catppuccinSkin} $out/plugins/roundcube_catppuccin
  '';
in
{
  services.roundcube = {
    enable = true;
    hostName = "mail.iwakura.page";
    package = roundcubeWithSkin;
    extraConfig = ''
      $config['default_host'] = 'localhost';
      $config['default_port'] = 143;
      $config['smtp_server'] = 'ssl://localhost';
      $config['smtp_port'] = 465;
      $config['smtp_auth_type'] = 'LOGIN';
      $config['smtp_conn_options'] = [
        'ssl' => [
          'verify_peer'      => false,
          'verify_peer_name' => false,
          'allow_self_signed' => true,
        ],
      ];
      $config['plugins'] = ['roundcube_catppuccin'];
    '';
  };

  services.nginx = {
    enable = true;
    virtualHosts."mail.iwakura.page" = {
      enableACME = false;
      forceSSL = false;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
