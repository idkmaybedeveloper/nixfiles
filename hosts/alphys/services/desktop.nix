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
  # the session itself (sway.desktop for ly, polkit rules, xwayland) - the
  # window manager config lives in home.nix
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # sway has no portal of its own, so ScreenCast (OBS's "Screen Capture
  # (PipeWire)" source) needs xdg-desktop-portal-wlr explicitly.
  # gtk portal stays for file pickers etc, wlr only handles screenshot/screencast.
  xdg.portal = {
    enable = true;
    wlr = {
      enable = true;
      # default chooser_type shells out to slurp/wofi/etc to pick an output
      # interactively; with a single laptop screen there's nothing to pick,
      # so skip the chooser entirely and grab the only output there is.
      settings.screencast.chooser_type = "none";
    };
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # lid close -> actually suspend (screen off, real sleep).
  # NOTE(lain): logind alone wasn't firing this on the SL3, so sway also binds
  # the lid switch itself (bindswitch in home.nix). both paths end in the same
  # `systemctl suspend`, and asking a suspending system to suspend is a no-op.
  # locking is handled by swayidle's before-sleep hook in home.nix,
  # since HandleLidSwitch=lock alone doesn't turn the screen off.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "suspend";
    HandlePowerKey = "suspend";
  };

  # Configure keymap (sway sets its own via the input blocks in home.nix)
  services.xserver.xkb = {
    layout = "us,ru";
    variant = "";
    options = "grp:alt_shift_toggle";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
}
