{ pkgs, lib, ... }:

let
  app = "/Applications/authentik Agent.app";
  stateDir = "/opt/authentik";
  logDir = "/Library/Logs/io.goauthentik";

  sysdConfig = (pkgs.formats.json { }).generate "authentik-sysd-config.json" {
    debug = false;
    domains = "${stateDir}/domains";
    runtime = "${stateDir}/runtime";
  };

  nativeHostDirs = {
    chrome = [
      "/Library/Google/Chrome/NativeMessagingHosts"
      "/Library/Application Support/Chromium/NativeMessagingHosts"
      "/Library/Microsoft/Edge/NativeMessagingHosts"
    ];
    firefox = [ "/Library/Application Support/Mozilla/NativeMessagingHosts" ];
  };

  installNativeHosts = lib.concatStrings (
    lib.mapAttrsToList (
      flavour: dirs:
      lib.concatMapStrings (dir: ''
        install -d -m 0755 ${lib.escapeShellArg dir}
        install -m 0644 ${lib.escapeShellArg "${app}/Contents/Resources/browser-host-${flavour}.json"} ${lib.escapeShellArg "${dir}/io.goauthentik.platform.json"} || true
      '') dirs
    ) nativeHostDirs
  );

  akCli = pkgs.runCommand "authentik-cli" { } ''
    mkdir -p $out/bin
    ln -s ${lib.escapeShellArg "${app}/Contents/MacOS/ak"} $out/bin/ak
    ln -s ${lib.escapeShellArg "${app}/Contents/MacOS/ak-vault"} $out/bin/ak-vault
  '';
in
{
  launchd.daemons.authentik-sysd.serviceConfig = {
    Label = "io.goauthentik.platform.sysd";
    ProgramArguments = [
      "${app}/Contents/MacOS/ak-sysd"
      "--config"
      "${stateDir}/config/config.json"
      "agent"
    ];
    UserName = "root";
    RunAtLoad = true;
    KeepAlive = true;
    StandardOutPath = "${logDir}/sysd.log";
    StandardErrorPath = "${logDir}/sysd.log";
  };

  system.activationScripts.preActivation.text = ''
    install -d -m 0755 ${logDir}
    install -d -m 0700 ${stateDir} ${stateDir}/config ${stateDir}/domains ${stateDir}/runtime
    install -m 0600 ${sysdConfig} ${stateDir}/config/config.json
  '';

  system.activationScripts.postActivation.text = lib.mkAfter installNativeHosts;

  environment.systemPackages = [ akCli ];
}