{ config, pkgs, ... }:

{
  services.xserver.enable = true;

  services.displayManager.gdm.enable = true;
  programs.driftwm.enable = true;

  # lid close -> actually suspend (screen off, real sleep).
  # locking itself is handled by swayidle's before-sleep hook in home.nix,
  # since HandleLidSwitch=lock alone doesn't turn the screen off.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "suspend";
  };

  # Configure keymap (used by GDM greeter; driftwm sets its own via config.toml)
  services.xserver.xkb = {
    layout = "us,ru";
    variant = "";
    options = "grp:alt_shift_toggle";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
}
