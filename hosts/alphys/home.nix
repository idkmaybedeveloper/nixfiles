{ pkgs, ... }:
let
  wallpaper = pkgs.fetchurl {
    url = "https://cloud.wejust.rest/f90b50d267a041ad8ff286c9d7bcdefc81644e38193deb8ce357d860a0f3902d/meowmeow.jpg";
    hash = "sha256-+QtQ0megQa2P8obJ17ze/IFkTjgZPeuM41fYYKDzkC0=";
  };

  # GIT_ASKPASS helper: prompts via gum (TUI) instead of the default
  # terminal echo prompt when git asks for an https username/password.
  gitAskpassGum = pkgs.writeShellScript "git-askpass-gum" ''
    ${pkgs.gum}/bin/gum input --password --placeholder "$1" </dev/tty
  '';

  lockCmd = "${pkgs.swaylock}/bin/swaylock -f -c 000000";
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
        # niri implements neither wlr-output-power-management nor DPMS via wlopm,
        # so blanking goes through its own IPC action instead
        timeout = 300;
        command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
        resumeCommand = "${pkgs.niri}/bin/niri msg action power-on-monitors";
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

  # niri compositor config: https://github.com/YaLTeR/niri/wiki/Configuration:-Overview
  xdg.configFile."niri/config.kdl".text = ''
    input {
        keyboard {
            xkb {
                layout "us,ru"
                options "grp:win_space_toggle"
            }
        }

        touchpad {
            tap
            natural-scroll
            accel-speed 0.3
        }

        mouse {
            accel-speed 0.6
        }
    }

    /*
     * NOTE(lain): the SL3 panel is 2256x1504 @ 13.5", so 1.0 is tiny and 2.0 is huge.
     * uncomment and tweak if the default (niri picks 1.0) is unreadable; niri does
     * fractional scaling properly, so 1.5 is fine here.
     *
     * output "eDP-1" {
     *     scale 1.5
     * }
     */

    layout {
        gaps 8
        center-focused-column "never"

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }
        default-column-width { proportion 0.5; }

        focus-ring {
            width 2
            active-color "#89b4fa"
            inactive-color "#313244"
        }

        border {
            off
        }
    }

    // niri ships no background of its own, only a flat color behind the wallpaper
    spawn-at-startup "${pkgs.swaybg}/bin/swaybg" "-m" "fill" "-i" "${wallpaper}"
    spawn-at-startup "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
    // night mode always on
    spawn-at-startup "${pkgs.wlsunset}/bin/wlsunset" "-t" "2700" "-T" "2701" "-S" "06:00" "-s" "18:00"

    // X11 apps: the nixos niri module leaves xwayland off, satellite covers it
    xwayland-satellite {
        path "${pkgs.xwayland-satellite}/bin/xwayland-satellite"
    }

    prefer-no-csd
    screenshot-path "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png"

    hotkey-overlay {
        skip-at-startup
    }

    binds {
        Mod+Shift+Slash { show-hotkey-overlay; }

        Mod+Return { spawn "${pkgs.alacritty}/bin/alacritty"; }
        Mod+D { spawn "${pkgs.fuzzel}/bin/fuzzel"; }
        Mod+N { spawn "${pkgs.swaynotificationcenter}/bin/swaync-client" "-t"; }
        Mod+Alt+L { spawn "${pkgs.swaylock}/bin/swaylock" "-f" "-c" "000000"; }

        XF86AudioRaiseVolume allow-when-locked=true { spawn "${pkgs.wireplumber}/bin/wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn "${pkgs.wireplumber}/bin/wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
        XF86AudioMute allow-when-locked=true { spawn "${pkgs.wireplumber}/bin/wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
        XF86AudioMicMute allow-when-locked=true { spawn "${pkgs.wireplumber}/bin/wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }

        XF86MonBrightnessUp allow-when-locked=true { spawn "${pkgs.brightnessctl}/bin/brightnessctl" "--class=backlight" "set" "5%+"; }
        XF86MonBrightnessDown allow-when-locked=true { spawn "${pkgs.brightnessctl}/bin/brightnessctl" "--class=backlight" "set" "5%-"; }

        XF86AudioPlay allow-when-locked=true { spawn "${pkgs.playerctl}/bin/playerctl" "play-pause"; }
        XF86AudioNext allow-when-locked=true { spawn "${pkgs.playerctl}/bin/playerctl" "next"; }
        XF86AudioPrev allow-when-locked=true { spawn "${pkgs.playerctl}/bin/playerctl" "previous"; }

        Mod+Q { close-window; }

        Mod+H { focus-column-left; }
        Mod+J { focus-window-down; }
        Mod+K { focus-window-up; }
        Mod+L { focus-column-right; }
        Mod+Left { focus-column-left; }
        Mod+Down { focus-window-down; }
        Mod+Up { focus-window-up; }
        Mod+Right { focus-column-right; }

        Mod+Ctrl+H { move-column-left; }
        Mod+Ctrl+J { move-window-down; }
        Mod+Ctrl+K { move-window-up; }
        Mod+Ctrl+L { move-column-right; }
        Mod+Ctrl+Left { move-column-left; }
        Mod+Ctrl+Down { move-window-down; }
        Mod+Ctrl+Up { move-window-up; }
        Mod+Ctrl+Right { move-column-right; }

        Mod+Home { focus-column-first; }
        Mod+End { focus-column-last; }

        Mod+Page_Down { focus-workspace-down; }
        Mod+Page_Up { focus-workspace-up; }
        Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
        Mod+Ctrl+Page_Up { move-column-to-workspace-up; }

        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }

        Mod+Ctrl+1 { move-column-to-workspace 1; }
        Mod+Ctrl+2 { move-column-to-workspace 2; }
        Mod+Ctrl+3 { move-column-to-workspace 3; }
        Mod+Ctrl+4 { move-column-to-workspace 4; }
        Mod+Ctrl+5 { move-column-to-workspace 5; }
        Mod+Ctrl+6 { move-column-to-workspace 6; }
        Mod+Ctrl+7 { move-column-to-workspace 7; }
        Mod+Ctrl+8 { move-column-to-workspace 8; }
        Mod+Ctrl+9 { move-column-to-workspace 9; }

        Mod+Comma { consume-window-into-column; }
        Mod+Period { expel-window-from-column; }

        Mod+R { switch-preset-column-width; }
        Mod+Shift+R { switch-preset-window-height; }
        Mod+C { center-column; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }
        Mod+Shift+Minus { set-window-height "-10%"; }
        Mod+Shift+Equal { set-window-height "+10%"; }

        Mod+V { toggle-window-floating; }
        Mod+Shift+V { switch-focus-between-floating-and-tiling; }
        Mod+Tab repeat=false { toggle-overview; }

        Print { screenshot; }
        Ctrl+Print { screenshot-screen; }
        Alt+Print { screenshot-window; }

        Mod+Shift+P { power-off-monitors; }
        Mod+Shift+E { quit; }
    }
  '';
}
