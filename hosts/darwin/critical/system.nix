{ config, pkgs, ... }:

let
  wallpaper = pkgs.fetchurl {
    url = "https://cloud.wejust.rest/4462f06236b7e78138fda49fc8e1f55f0dcf2ee833656121427beb1adfeddcd3/stupidcat.png";
    hash = "sha256-RGLwYja354E4/aSfyOH1Xw3PLugzZWEhQnvrGt/t3NM=";
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
