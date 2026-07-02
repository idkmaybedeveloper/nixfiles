{ pkgs, ... }: {
  home.stateVersion = "25.11";

  imports = [ ./editor ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "lain";
      user.email = "lain@iwakura.page";
    };
  };

  dconf = {
    enable = true;

    settings = {
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      "org/gnome/desktop/background" = {
        picture-uri-dark = "file://${pkgs.nixos-artwork.wallpapers.nineish-catppuccin-mocha.src}";
      };

      "org/gnome/desktop/peripherals/mouse".speed = 0.6;
      "org/gnome/desktop/peripherals/touchpad".speed = 0.5;

      "org/gnome/desktop/wm/preferences".button-layout = "appmenu:minimize,maximize,close";

      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          blur-my-shell.extensionUuid
          appindicator.extensionUuid
          dash-to-dock.extensionUuid
        ];
        favorite-apps = [
          "org.gnome.Nautilus.desktop"
          "io.github.kukuruzka165.materialgram.desktop"
          "io.m51.Gelly.desktop"
          "com.raggesilver.BlackBox.desktop"
          "helium.desktop"
          "codium.desktop"
        ];
      };

      "org/gnome/shell/extensions/dash-to-dock" = {
        dock-position = "bottom";
        autohide = true;
        icon-size = 32;
      };
    };
  };
}