{ config, pkgs, ... }:

{
  services.xserver.enable = true;

  #provides the dconf-service dbus .service file so home-manager's
  #dconf.settings can dbus-activate ca.desrt.dconf during activation
  programs.dconf.enable = true;

  # plasma 6 on wayland; sddm is the greeter that actually knows how to hand a
  # wayland session over (plasma ships plasmax11 too, sddm lists both)
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "catppuccin-mocha-blue";
    #the catppuccin theme is plain qml: svg icons + the virtual keyboard button
    extraPackages = with pkgs.kdePackages; [
      qtsvg
      qtvirtualkeyboard
    ];
  };
  environment.systemPackages = [ pkgs.catppuccinAlphys.sddm ];

  services.desktopManager.plasma6.enable = true;

  #NOTE(lain): ly is kept here, disabled, so that jumping back to it is a
  #one-line flip (`enable = true` here, `false` on sddm above)
  services.displayManager.ly = {
    enable = false;
    settings = {
      animation = "dur_file";
      #NOTE(kroot): https://codeberg.org/fairyglade/ly/src/branch/master/src/config/migrator.zig
      #ly's nixpkgs module ships a minimal defaultConfig with no color fields, which trips
      #the legacy-config migrator into forcing full_color = false; our .dur theme is
      #colorFormat "256" and needs full_color = true, so set it explicitly.
      full_color = true;
      dur_file_path = toString (
        pkgs.fetchurl {
          url = "https://cloud.wejust.rest/7d19b4c2592af7f19d2eb5413b33049d01bf8b69e0fae188cead2ef61bb79bd8/blackhole-smooth-240x67.dur";
          hash = "sha256-fRm0wlkq9/GdLrVBOzMEnQG/i2ng+uGIzq0u9hu3m9g=";
        }
      );
    };
  };

  #plasma6 pulls in xdg-desktop-portal-kde itself (screencast/screenshot go
  #through kwin), the gtk portal stays around for gtk apps' file pickers
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  #NOTE(lain): powerdevil takes a logind inhibitor and handles the lid itself
  #(see programs.plasma.powerdevil in home.nix)
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "suspend";
    HandlePowerKey = "suspend";
  };

  #x11 keymap for the greeter/xwayland; the plasma session sets its own via
  #programs.plasma.input.keyboard in home.nix
  services.xserver.xkb = {
    layout = "us,ru";
    variant = "";
    options = "grp:alt_shift_toggle";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
}
