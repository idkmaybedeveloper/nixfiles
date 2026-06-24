#NOTE:NOTE:FUCKING:README:NOTE: i am not using helix currently so i'll delete this maybe
{ pkgs, ... }:

{
  programs.helix = {
    enable = true;

    # catppuccin mocha ships with helix out of the box, no extension needed
    settings = {
      theme = "catppuccin_mocha";
      editor = {
        line-number = "relative";
        cursorline = true;
        color-modes = true;
        bufferline = "multiple";
        true-color = true;
        auto-format = true;
        completion-trigger-len = 1;
        idle-timeout = 50;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides = {
          render = true;
          character = "|";
        };
        statusline = {
          left = [
            "mode"
            "spinner"
            "file-name"
            "file-modification-indicator"
          ];
          right = [
            "diagnostics"
            "selections"
            "position"
            "file-encoding"
            "file-type"
          ];
        };
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };
        file-picker.hidden = false;
      };
      keys.normal = {
        # space e -> file explorer, same muscle memory as the nvim setup
        space.e = "file_explorer";
        "C-h" = "jump_view_left";
        "C-l" = "jump_view_right";
      };
    };

    # extraPackages provides the lsp/formatter binaries on PATH for helix.
    # languages mirror what zed/codium already have configured.
    languages = {
      language-server = {
        nil.command = "${pkgs.nil}/bin/nil";
        gopls.command = "${pkgs.gopls}/bin/gopls";
        rust-analyzer.command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
        clangd.command = "${pkgs.clang-tools}/bin/clangd";
        terraform-ls = {
          command = "${pkgs.terraform-ls}/bin/terraform-ls";
          args = [ "serve" ];
        };
        taplo.command = "${pkgs.taplo}/bin/taplo";
        marksman.command = "${pkgs.marksman}/bin/marksman";
        ocamllsp.command = "${pkgs.ocamlPackages.ocaml-lsp}/bin/ocamllsp";
        bash-language-server = {
          command = "${pkgs.bash-language-server}/bin/bash-language-server";
          args = [ "start" ];
        };
      };

      language = [
        {
          name = "nix";
          language-servers = [ "nil" ];
          auto-format = true;
          formatter.command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
        }
        {
          name = "go";
          language-servers = [ "gopls" ];
          auto-format = true;
        }
        {
          name = "rust";
          language-servers = [ "rust-analyzer" ];
          auto-format = true;
        }
        {
          name = "c";
          language-servers = [ "clangd" ];
        }
        {
          name = "cpp";
          language-servers = [ "clangd" ];
        }
        {
          name = "hcl";
          language-servers = [ "terraform-ls" ];
        }
        {
          name = "toml";
          language-servers = [ "taplo" ];
        }
        {
          name = "markdown";
          language-servers = [ "marksman" ];
        }
        {
          name = "ocaml";
          language-servers = [ "ocamllsp" ];
        }
        {
          name = "bash";
          language-servers = [ "bash-language-server" ];
        }
      ];
    };

    extraPackages = with pkgs; [
      nil
      gopls
      rust-analyzer
      clang-tools
      terraform-ls
      taplo
      marksman
      ocamlPackages.ocaml-lsp
      bash-language-server
      nixfmt-rfc-style
    ];
  };
}
