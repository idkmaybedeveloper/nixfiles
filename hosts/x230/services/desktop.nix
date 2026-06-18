{ config, pkgs, ... }:

{
  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  services.desktopManager.gnome.extraGSettingsOverrides = ''
    [org/gnome/desktop/wm/preferences]
    button-layout = 'minimize,maximize,close:'
  '';
  

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  # NOTE: gdm.wayland option dropped with GNOME 50, wayland is the only mode now
  services.desktopManager.gnome.enable = true;
  
  #environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us,ru";
    variant = "";
    options = "grp:alt_shift_toggle";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  
  #services.xsession.pointerCursor = {
  #  package = pkgs.gnome.adwaita-icon-theme;
  #  name = "Adwaita";
  #  size = 38;
  #};
  environment.gnome.excludePackages = [  pkgs.epiphany ];
}
