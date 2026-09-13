{ callPackage }:

let
  common = callPackage ./common.nix { };
in
with common;
{
  bitwarden = downloadAndInstallDmgApp {
    url = "https://bitwarden.com/download/?app=desktop&platform=macos&variant=dmg";
    filename = "Bitwarden.app";
  };
}