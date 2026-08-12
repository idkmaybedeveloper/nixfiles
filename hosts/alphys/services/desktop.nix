{ config, pkgs, ... }:

{
  services.xserver.enable = true;

  # provides the dconf-service dbus .service file so home-manager's
  # dconf.settings can dbus-activate ca.desrt.dconf during activation
  programs.dconf.enable = true;

  services.displayManager.ly = {
    enable = true;
    settings = {
      animation = "dur_file";
      # NOTE(kroot): https://codeberg.org/fairyglade/ly/src/branch/master/src/config/migrator.zig
      # ly's nixpkgs module ships a minimal defaultConfig with no color fields, which trips
      # the legacy-config migrator into forcing full_color = false; our .dur theme is
      # colorFormat "256" and needs full_color = true, so set it explicitly.
      full_color = true;
      dur_file_path = toString (
        pkgs.fetchurl {
          url = "https://cloud.wejust.rest/7d19b4c2592af7f19d2eb5413b33049d01bf8b69e0fae188cead2ef61bb79bd8/blackhole-smooth-240x67.dur";
          hash = "sha256-fRm0wlkq9/GdLrVBOzMEnQG/i2ng+uGIzq0u9hu3m9g=";
        }
      );
    };
  };
  programs.niri.enable = true;

  # niri talks to xdg-desktop-portal-gnome for ScreenCast (OBS's "Screen Capture
  # (PipeWire)" source) and the gnome module pulls that in itself; gtk stays for
  # the file picker / access / notification backends its portal config points at.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # the niri module leaves xwayland off, X11 clients go through
  # xwayland-satellite (see the xwayland-satellite block in home.nix)
  programs.xwayland.enable = true;

  # lid close -> actually suspend (screen off, real sleep).
  # locking itself is handled by swayidle's before-sleep hook in home.nix,
  # since HandleLidSwitch=lock alone doesn't turn the screen off.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "suspend";
    HandlePowerKey = "suspend";
  };

  # Configure keymap (niri sets its own via config.kdl)
  services.xserver.xkb = {
    layout = "us,ru";
    variant = "";
    options = "grp:alt_shift_toggle";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
}
