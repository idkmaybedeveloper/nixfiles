{ pkgs, ... }:
let
  wallpaper = pkgs.fetchurl {
    url = "https://cloud.wejust.rest/f90b50d267a041ad8ff286c9d7bcdefc81644e38193deb8ce357d860a0f3902d/meowmeow.jpg";
    hash = "sha256-+QtQ0megQa2P8obJ17ze/IFkTjgZPeuM41fYYKDzkC0=";
  };
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

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "sans-serif:size=11";
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
        font-family: sans-serif;
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
    accel_speed = 0.2

    [background]
    type = "wallpaper"
    path = "${wallpaper}"

    [decorations]
    bg_color = "#1e1e2e"
    fg_color = "#cdd6f4"

    [keybindings]
    "mod+n" = "spawn swaync-client -t"
  '';
}
