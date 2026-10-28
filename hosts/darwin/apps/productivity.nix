{ callPackage, fetchurl }:

let
  common = callPackage ./common.nix { };
in
with common;
{
  bitwarden = downloadAndInstallDmgApp {
    url = "https://bitwarden.com/download/?app=desktop&platform=macos&variant=dmg";
    filename = "Bitwarden.app";
  };

  # NOTE: the rest of the agent (sysd daemon, config, browser hosts) lives in services/authentik.nix
  authentik = installAppFromPkg rec {
    version = "0.72.5";
    pkg = fetchurl {
      url = "https://github.com/goauthentik/platform/releases/download/v${version}/authentik.Agent.Installer.pkg";
      hash = "sha256-jhDRAQA6x1+NrDm44eYeN3x8JJumbcIMjUfDIY6x+lU=";
    };
    filename = "agent.pkg/Payload/authentik Agent.app";
    afterInstall = ''
      /usr/bin/pkill -x ak-browser-support || true
      /bin/launchctl kickstart -k system/io.goauthentik.platform.sysd || true
    '';
  };
}
