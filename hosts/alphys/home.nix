{ pkgs, ... }:
let
  wallpaper = pkgs.fetchurl {
    url = "https://cloud.wejust.rest/f90b50d267a041ad8ff286c9d7bcdefc81644e38193deb8ce357d860a0f3902d/meowmeow.jpg";
    hash = "sha256-+QtQ0megQa2P8obJ17ze/IFkTjgZPeuM41fYYKDzkC0=";
  };

  # screenshots go to ~/Pictures/Screenshots and also to the clipboard via wl-copy
  screenshotFull = pkgs.writeShellScript "screenshot-full" ''
    mkdir -p "$HOME/Pictures/Screenshots"
    grim - | tee "$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png" | wl-copy
  '';
  screenshotRegion = pkgs.writeShellScript "screenshot-region" ''
    mkdir -p "$HOME/Pictures/Screenshots"
    grim -g "$(slurp -d)" - | tee "$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png" | wl-copy
  '';
  screenshotWindow = pkgs.writeShellScript "screenshot-window" ''
    mkdir -p "$HOME/Pictures/Screenshots"
    driftwm msg screenshot window -o - | tee "$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png" | wl-copy
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
    };
  };

  # dark theme for gtk/qt apps (no gnome-shell to flip this globally anymore)
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  # xdg-desktop-portal-gtk/gnome read this for the org.freedesktop.appearance
  # color-scheme portal (libadwaita apps, GTK4 dark mode)
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

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=11";
        terminal = "${pkgs.alacritty}/bin/alacritty";
      };
      colors = {
        background = "1e1e2edd";
        text = "cdd6f4ff";
        match = "89b4faff";
        selection = "313244ff";
        selection-text = "cdd6f4ff";
        border = "89b4faff";
      };
      border.radius = 8;
    };
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 28;
        modules-left = [ "clock" ];
        modules-center = [ ];
        modules-right = [
          "tray"
          "pulseaudio"
          "network"
          "battery"
        ];
        clock.format = "{:%Y-%m-%d %H:%M}";
        battery = {
          format = "{capacity}% {icon}";
          format-icons = [
            "󰁺"
            "󰁽"
            "󰂀"
            "󰂂"
            "󰁹"
          ];
        };
        network.format = "{ifname}: {ipaddr}";
        network.format-disconnected = "disconnected";
        pulseaudio.format = "{volume}% {icon}";
        pulseaudio.format-muted = "muted";
        tray.spacing = 8;
      };
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", sans-serif;
        font-size: 12px;
      }
      window#waybar {
        background: rgba(30, 30, 46, 0.85);
        color: #cdd6f4;
      }
      #battery, #network, #pulseaudio, #tray, #clock {
        padding: 0 8px;
      }
    '';
  };

  services.swaync.enable = true;

  # idle handling: screen off after 5 min, lock+suspend after 10 min,
  # and always lock right before any suspend (lid close, manual suspend, etc).
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 300;
        command = "${pkgs.wlopm}/bin/wlopm --off '*'";
        resumeCommand = "${pkgs.wlopm}/bin/wlopm --on '*'";
      }
      {
        timeout = 600;
        command = "${pkgs.swaylock}/bin/swaylock -f -c 000000";
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock}/bin/swaylock -f -c 000000";
      }
      {
        event = "lock";
        command = "${pkgs.swaylock}/bin/swaylock -f -c 000000";
      }
    ];
  };

  # driftwm compositor config: https://github.com/malbiruk/driftwm/blob/master/docs/config.md
  xdg.configFile."driftwm/config.toml".text = ''
    autostart = [
      "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1",
      "waybar",
      "swaync",
    ]

    [input.keyboard]
    layout = "us,ru"
    options = "grp:alt_shift_toggle"

    [input.trackpad]
    natural_scroll = true
    tap_to_click = true
    accel_speed = 0.3

    [input.mouse]
    accel_speed = 0.6

    [background]
    type = "wallpaper"
    path = "${wallpaper}"

    [decorations]
    bg_color = "#1e1e2e"
    fg_color = "#cdd6f4"

    [keybindings]
    "mod+n" = "spawn swaync-client -t"
    "Print" = "spawn ${screenshotFull}"
    "shift+Print" = "spawn ${screenshotRegion}"
    "ctrl+Print" = "spawn ${screenshotWindow}"
  '';
}
