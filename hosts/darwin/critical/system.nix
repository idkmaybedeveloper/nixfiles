{ config, pkgs, ... }:

let
  wallpaper = pkgs.fetchurl {
    url = "https://cloud.wejust.rest/f57ca5e1878ee573d0433cb5902d2cd1286af0728a8be50fd9be0e07877b704b/Foxconn_Data_Center,_Mount_Pleasant_(53444925939).jpg";
    hash = "sha256-9Xyl4YeO5XPQQzy1kC0s0Shq8HKKi+UP2b4OB4d7cEs=";
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
