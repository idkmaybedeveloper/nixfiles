{ config, pkgs, ... }:

let
  wallpaper = pkgs.fetchurl {
    url = "https://cloud.wejust.rest/7a395c38af3e39ada0e8aef5049ebb287bd0a09df4d0f403554e85586d596a87/aluminium-os-stock-3636x3636-26372.jpeg";
    hash = "sha256-ejlcOK8+Oa2g6K71BJ67KHvQoJ300PQDVU6FWG1Zaoc=";
  };
in
{
  security.pki.certificateFiles = [
    (pkgs.fetchurl {
      url = "http://setupca.at.cuddles.rs/"; # 192.168.1.65
      hash = "sha256-AvLe+5dSqBqS8cxfyasje/UIVI01ky3xxzXV4sTOb/s=";
    })
  ];

  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      ApplePressAndHoldEnabled = false;
    };
  };

  system.nvram.variables = {
    "boot-args" = "-arm64e_preview_abi -v";
  };

  system.activationScripts.postActivation.text = ''
    echo "nya :33"
  '';

  system.activationScripts.extraActivation.text = ''
    launchctl asuser "$(id -u lain)" sudo -u lain /usr/bin/osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"${wallpaper}\""
  ''; # :scared:
}
