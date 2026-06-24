{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./pkgs ];

  environment.etcBackupExtension = ".bak";
  system.stateVersion = "24.05";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  time.timeZone = "Europe/Moscow";
}
