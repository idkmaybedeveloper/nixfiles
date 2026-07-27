{ config, pkgs, ... }:

let
  wallpaper = pkgs.fetchurl {
    url = "https://cloud.wejust.rest/b9a35e169802c1b388dacd34730d237929ff133f88f4d9656337ac771b0f846b/nyamreow.jpg"; # https://x.com/Vulkiri/status/2080956809582403896
    hash = "sha256-uaNeFpgCwbOI2s00cw0jeSn/Ez+I9NllYzesdxsPhGs=";
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
