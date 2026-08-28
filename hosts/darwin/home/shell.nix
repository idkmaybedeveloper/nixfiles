{ config, pkgs, ... }:
{
  home.sessionVariables = {
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
    LIBRARY_PATH = "${pkgs.libiconv}/lib"; # :${pkgs.mcfgthreads-static}/lib";
    EDITOR = "vim";
    ANDROID_HOME = "${config.home.homeDirectory}/.android-sdk";
    ANDROID_SDK_ROOT = "${config.home.homeDirectory}/.android-sdk";
    THEOS = "$HOME/theos";
    NOCC_SERVERS = "192.168.1.65:43211";
    NOCC_GO_EXECUTABLE = "/Users/lain/.local/bin/nocc-daemon";
    NOCC_LOG_FILENAME = "/tmp/nocc-client.log";
    GEM_HOME = "/Users/lain/.gem/ruby/3.3.0";
    GEM_PATH = "/Users/lain/.gem/ruby/3.3.0";
    CLICOLOR = "1";
    FORCE_COLOR = "1";
    GPG_TTY = "$(tty)";
  };

  programs.fish = {
    enable = true;
    shellAbbrs = {
      v = "vim";
      gaa = "git add .";
      gcm = "git commit -m";
      rmail = "TERM=xterm-256color ssh mail";
      code = ''"/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"'';
      bazel = "bazelisk"; # "Альцгеймер помогает от кофе"
    };
    interactiveShellInit = ''
      fish_add_path /Users/lain/.gem/ruby/3.3.0/bin
      fish_add_path /etc/profiles/per-user/lain/bin
      fish_add_path ~/.local/bin/kphp/bin/
      alias ls=eza
      fish_add_path ~/theos/bin/
      fish_add_path /Users/lain/.cargo/bin
      alias containerr='make -C /Users/lain/builds/seL4/seL4-CAmkES-L4v-dockerfiles user HOST_DIR=$(pwd)'
      fish_add_path $GEM_HOME/bin
      fish_add_path
      fish_add_path /usr/local/plan9/bin/
      # set -g pure_enable_nixdevshell true
      # set -g pure_enable_git true
      # set -g pure_show_system_time true
      # set -g pure_show_subsecond_command_duration true
      # set -g pure_threshold_command_duration 1
      if command -q nix-your-shell
        nix-your-shell fish | source
      end
    '';
    plugins = [
      {
        name = "grc";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-grc";
          rev = "61de7a8a0d7bda3234f8703d6e07c671992eb079";
          sha256 = "sha256-NQa12L0zlEz2EJjMDhWUhw5cz/zcFokjuCK5ZofTn+Q=";
        };
      }
      #{
      #  name = "nix.fish";
      #  src = pkgs.fetchFromGitHub {
      #   owner = "kpbaks";
      #   repo = "nix.fish";
      #   rev = "8a39e3e9be2e3a020a901eb9c8a2a9ffda8e3b50";
      #   sha256 = "sha256-4V91YQuC4UtcILE50gl4xBgr2rFAkzWx0APooMs4mYM=";
      # };
      #}
      #{
      #  name = "pure-fish";
      #  src = pkgs.fetchFromGitHub {
      #    owner = "pure-fish";
      #    repo = "pure";
      #    rev = "1c58b6972a4b611afc30299c6a882d95f3001639";
      #    sha256 = "sha256-bC0KGBcvnFYes58uht07Ar/0b6Pmr0XdkiVOPMes6W8=";
      #  };
      #}
    ];
  };
}
