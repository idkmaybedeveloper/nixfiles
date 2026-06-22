{ pkgs, ... }:
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
      "starlark"
      "ocaml"
      "erlang"
      "astro"
      "mdx"
      "wakatime"
      "dockerfile"
    ];

    userSettings = {
      theme = "Catppuccin Mocha";
      disable_ai = true;
      vim_mode = false;
      project_panel = {
        dock = "left";
      };
      auto_update = false;
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
      buffer_font_family = "Iosevka";
      ui_font_family = "Iosevka";
      lsp = {
        # pin starpls from nixpkgs instead of letting the bazel extension
        # pull a binary from github releases at runtime. starpls shells out to
        # a binary literally named `bazel` for `bazel info`, but we only have
        # bazelisk, so point it there explicitly via --bazel_path.
        starpls.binary = {
          path = "${pkgs.starpls}/bin/starpls";
          arguments = [
            "server"
            "--bazel_path=${pkgs.bazelisk}/bin/bazelisk"
          ];
        };
      };
      languages = {
        Starlark = {
          formatter = {
            external = {
              command = "${pkgs.bazel-buildtools}/bin/buildifier";
              arguments = [
                "-path"
                "{buffer_path}"
              ];
            };
          };
        };
      };
    };
  };
}
