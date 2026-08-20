{ config, pkgs, ... }:
let
  wallpaper = (import ../../lib/wallpapers { inherit pkgs; }).meowmeow;
  theme = pkgs.catppuccinAlphys;

  #GIT_ASKPASS helper: prompts via gum (TUI) instead of the default
  #terminal echo prompt when git asks for an https username/password.
  gitAskpassGum = pkgs.writeShellScript "git-askpass-gum" ''
    ${pkgs.gum}/bin/gum input --password --placeholder "$1" </dev/tty
  '';
in
{
  home.stateVersion = "25.11";

  imports = [ ./editor ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "lain";
      user.email = "lain@iwakura.page";
      core.askPass = "${gitAskpassGum}";
      credential.helper = "cache --timeout=28800";
    };
  };

  home.sessionVariables.GIT_ASKPASS = "${gitAskpassGum}";

  #plasma only themes qt; gtk apps get the matching catppuccin gtk theme here
  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-mocha-blue-standard";
      package = theme.gtk;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = theme.papirusFolders;
    };
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
    #home-manager 26.05 defaults gtk4.theme to null; catppuccin-gtk ships
    #gtk-4.0 assets, so keep the gtk3 theme applied there too
    gtk4.theme = config.gtk.theme;
  };

  #the org.freedesktop.appearance color-scheme portal reads this (libadwaita
  #apps, GTK4 dark mode)
  dconf = {
    enable = true;
    settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal.family = "JetBrainsMono Nerd Font";
        size = 11;
      };
    };
  };

  programs.plasma = {
    enable = true;

    workspace = {
      lookAndFeel = "Catppuccin-Mocha-Blue";
      colorScheme = "CatppuccinMochaBlue";
      iconTheme = "Papirus-Dark";
      cursor = {
        theme = "catppuccin-mocha-blue-cursors";
        size = 24;
      };
      wallpaper = wallpaper;
    };

    # aurorae window decorations - plasma-manager has no option for the
    # decoration theme, so poke kwinrc directly. the __aurorae__svg__ prefix is
    # how kwin names aurorae themes internally.
    configFile.kwinrc."org.kde.kdecoration2" = {
      library = "org.kde.kwin.aurorae";
      theme = "__aurorae__svg__CatppuccinMocha-Modern";
    };

    kwin.nightLight = {
      # the old sway setup ran wlsunset -t 2700 -T 2701, i.e. warm around the
      # clock; constant mode is the same thing without the fake day/night split
      enable = true;
      mode = "constant";
      temperature.night = 2700;
    };

    input.keyboard = {
      layouts = [
        { layout = "us"; }
        { layout = "ru"; }
      ];
      options = [ "grp:win_space_toggle" ];
    };

    # SL3's elan-behind-surface-hid touchpad; ids from /proc/bus/input/devices
    input.touchpads = [
      {
        enable = true;
        name = "Microsoft Surface 045E:09AF Touchpad";
        vendorId = "045E";
        productId = "09AF";

        tapToClick = true;
        naturalScroll = true;
        pointerSpeed = 0.3;
        accelerationProfile = "default";
        disableWhileTyping = true;
        tapAndDrag = true;
        tapDragLock = true;
        scrollMethod = "twoFingers";
        scrollSpeed = 0.3;
        rightClickMethod = "twoFingers";
        twoFingerTap = "rightClick";
      }
    ];

    kscreenlocker = {
      autoLock = true;
      timeout = 5;
      lockOnResume = true;
      passwordRequired = true;
      passwordRequiredDelay = 0;
    };

    powerdevil = {
      AC = {
        powerButtonAction = "sleep";
        whenLaptopLidClosed = "sleep";
        turnOffDisplay = {
          idleTimeout = 330;
          idleTimeoutWhenLocked = "immediately";
        };
        autoSuspend.action = "nothing";
      };
      battery = {
        powerButtonAction = "sleep";
        whenLaptopLidClosed = "sleep";
        turnOffDisplay = {
          idleTimeout = 330;
          idleTimeoutWhenLocked = "immediately";
        };
        dimDisplay = {
          enable = true;
          idleTimeout = 180;
        };
        autoSuspend = {
          action = "sleep";
          idleTimeout = 600;
        };
      };
      lowBattery = {
        powerButtonAction = "sleep";
        whenLaptopLidClosed = "sleep";
        turnOffDisplay = {
          idleTimeout = 120;
          idleTimeoutWhenLocked = "immediately";
        };
        autoSuspend = {
          action = "sleep";
          idleTimeout = 300;
        };
      };
    };

    # spectacle replaces the grim/slurp scripts; same keys as before
    spectacle.shortcuts = {
      captureEntireDesktop = "Print";
      captureRectangularRegion = "Shift+Print";
      captureActiveWindow = "Ctrl+Print";
    };

    hotkeys.commands."launch-terminal" = {
      name = "Launch Alacritty";
      key = "Meta+Return";
      command = "${pkgs.alacritty}/bin/alacritty";
    };
  };
}
