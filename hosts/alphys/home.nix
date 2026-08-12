{ pkgs, lib, ... }:
let
  wallpaper = (import ../../lib/wallpapers { inherit pkgs; }).meowmeow;

  # screenshots go to ~/Pictures/Screenshots and also to the clipboard via wl-copy
  screenshotFull = pkgs.writeShellScript "screenshot-full" ''
    mkdir -p "$HOME/Pictures/Screenshots"
    ${pkgs.grim}/bin/grim - \
      | tee "$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png" \
      | ${pkgs.wl-clipboard}/bin/wl-copy
  '';
  screenshotRegion = pkgs.writeShellScript "screenshot-region" ''
    mkdir -p "$HOME/Pictures/Screenshots"
    ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -d)" - \
      | tee "$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png" \
      | ${pkgs.wl-clipboard}/bin/wl-copy
  '';
  screenshotWindow = pkgs.writeShellScript "screenshot-window" ''
    mkdir -p "$HOME/Pictures/Screenshots"
    geometry=$(${pkgs.sway}/bin/swaymsg -t get_tree \
      | ${pkgs.jq}/bin/jq -r '.. | select(.focused? == true) | .rect
          | "\(.x),\(.y) \(.width)x\(.height)"')
    ${pkgs.grim}/bin/grim -g "$geometry" - \
      | tee "$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png" \
      | ${pkgs.wl-clipboard}/bin/wl-copy
  '';

  # GIT_ASKPASS helper: prompts via gum (TUI) instead of the default
  # terminal echo prompt when git asks for an https username/password.
  gitAskpassGum = pkgs.writeShellScript "git-askpass-gum" ''
    ${pkgs.gum}/bin/gum input --password --placeholder "$1" </dev/tty
  '';

  # meow
  lockCmd = toString (
    pkgs.writeShellScript "lock-session" ''
      ${pkgs.procps}/bin/pgrep -x swaylock >/dev/null && exit 0
      exec ${pkgs.swaylock}/bin/swaylock -f -c 000000
    ''
  );
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
    # niri --session brings up graphical-session.target with the wayland env
    # already imported, so the hm unit is enough (no autostart from the compositor)
    systemd.enable = true;
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
        clock.format = "{:%Y-%m-%d %H:%M:%S}";
        clock.interval = 1;
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
        command = "${pkgs.sway}/bin/swaymsg 'output * power off'";
        resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * power on'";
      }
      {
        timeout = 600;
        command = lockCmd;
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = lockCmd;
      }
      {
        event = "lock";
        command = lockCmd;
      }
    ];
  };

  # sway: https://github.com/swaywm/sway/wiki. the nixos side (session, polkit,
  # xwayland) lives in services/desktop.nix; this is just the wm config
  wayland.windowManager.sway = {
    enable = true;
    # the wrapped sway comes from programs.sway on the system side, so home
    # manager only writes the config - two swaypackages in PATH would fight
    package = null;
    checkConfig = false;

    config = {
      modifier = "Mod4";
      terminal = "${pkgs.alacritty}/bin/alacritty";
      menu = "${pkgs.fuzzel}/bin/fuzzel";

      # waybar runs as its own systemd unit, so no swaybar
      bars = [ ];

      input = {
        "type:keyboard" = {
          xkb_layout = "us,ru";
          xkb_options = "grp:win_space_toggle";
        };
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
          pointer_accel = "0.3";
        };
        "type:pointer" = {
          pointer_accel = "0.6";
        };
      };

      output."*".bg = "${wallpaper} fill";

      gaps.inner = 8;

      window = {
        border = 2;
        titlebar = false;
      };
      floating.titlebar = false;

      colors.focused = {
        border = "#89b4fa";
        background = "#1e1e2e";
        text = "#cdd6f4";
        indicator = "#89b4fa";
        childBorder = "#89b4fa";
      };
      colors.unfocused = {
        border = "#313244";
        background = "#1e1e2e";
        text = "#cdd6f4";
        indicator = "#313244";
        childBorder = "#313244";
      };

      startup = [
        { command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"; }
        # night mode always on
        {
          command = "${pkgs.wlsunset}/bin/wlsunset -t 2700 -T 2701 -S 06:00 -s 18:00";
        }
      ];

      keybindings = lib.mkOptionDefault {
        "Mod4+n" = "exec ${pkgs.swaynotificationcenter}/bin/swaync-client -t";
        "Mod4+Mod1+l" = "exec ${lockCmd}";

        "Print" = "exec ${screenshotFull}";
        "Shift+Print" = "exec ${screenshotRegion}";
        "Ctrl+Print" = "exec ${screenshotWindow}";

        "XF86AudioRaiseVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute" = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioMicMute" = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

        "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl --class=backlight set 5%+";
        "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl --class=backlight set 5%-";

        "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
        "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
        "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
      };

      # NOTE(lain): logind's HandleLidSwitch wasn't firing on this box, so sway
      # suspends on the lid switch itself. --locked so it still works with
      # swaylock up, --reload so a config reload doesn't leave it unbound.
      bindswitches."lid:on" = {
        action = "exec ${pkgs.systemd}/bin/systemctl suspend";
        locked = true;
        reload = true;
      };
    };
  };
}
