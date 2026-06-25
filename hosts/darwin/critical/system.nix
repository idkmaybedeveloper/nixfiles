{ config, pkgs, ... }:

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
    launchctl asuser "$(id -u lain)" sudo -u lain /usr/bin/osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"${pkgs.nixos-artwork.wallpapers.binary-black}/share/backgrounds/nixos/nix-wallpaper-binary-black.png\""
  ''; # :scared:
}
