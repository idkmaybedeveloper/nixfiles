{ ... }:
{
  programs.zed-editor = {
    enable = true;

    extensions = [
      "catppuccin"
      "nix"
      "proto"
      "toml"
      "java"
      "csharp"
      "terraform"
      "hcl"
      "bazel"
      "ocaml"
      "erlang"
      "astro"
      "mdx"
      "wakatime"
    ];

    userSettings = {
      theme = "Catppuccin Mocha";
      disable_ai = true;
      project_panel = {
        dock = "left";
      };
      vim_mode = true;
      auto_update = false;
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
      buffer_font_family = "Iosevka";
      ui_font_family = "Iosevka";
    };
  };
}
