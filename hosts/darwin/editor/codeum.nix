{ pkgs, vscode-extensions, ... }:

let
  marketplace = vscode-extensions.vscode-marketplace;
  open-vsx = vscode-extensions.open-vsx;

in
{
  programs.vscodium = {
    enable = true;
    profiles.default = {
      extensions = [
        open-vsx.peterj.proto
        marketplace.ms-dotnettools.vscode-dotnet-runtime
        marketplace.icsharpcode.ilspy-vscode
        open-vsx.redhat.java # redhah exploit gcc...
        open-vsx.wakatime.vscode-wakatime
        open-vsx.hashicorp.terraform
        marketplace.dedazamarks.tl
        open-vsx.barbosshack.crates-io
        open-vsx.tamasfe.even-better-toml
        marketplace.maximtrp.drone-ci
        marketplace.rust-lang.rust-analyzer
        marketplace.golang.go
        open-vsx.jnoortheen.nix-ide
        open-vsx.yzhang.markdown-all-in-one
        open-vsx.catppuccin.catppuccin-vsc
        marketplace.bazelbuild.vscode-bazel
        open-vsx.zaaack.markdown-editor
        open-vsx.unifiedjs.vscode-mdx
        open-vsx.maxking.forgejo-vscode
        open-vsx.hashicorp.hcl
        open-vsx.mrcrowl.hg
        open-vsx.mshr-h.veriloghdl
        open-vsx.ocamllabs.ocaml-platform
        open-vsx.erlang-ls.erlang-ls
        open-vsx.astro-build.astro-vscode
        marketplace.leonardssh.vscord
        open-vsx.kpumuk.thrift-weaver-vscode
        marketplace.ggml-org.llama-vscode
      ];
      userSettings = {
        "update.mode" = "none";
        "extensions.autoUpdate" = false;
        "extensions.autoCheckUpdates" = false;
        "window.autoDetectColorScheme" = true;
        "workbench.preferredDarkColorTheme" = "Catppuccin Mocha";
        "workbench.preferredLightColorTheme" = "Catppuccin Latte";
        "nix.serverPath" = "nil";
        "dotnetAcquisitionExtension.existingDotnetPath" = [
          {
            extensionId = "icsharpcode.ilspy-vscode";
            path = "${pkgs.dotnet-sdk_10}/bin/dotnet";
          }
        ];
        "workbench.activityBar.location" = "top";
        "redhat.telemetry.enabled" = false;
        # NOTE: vscode-bazel searches for a `bazel` in PATH,
        # but we have only bazelisk SOOOOO just point it there
        "bazel.executable" = "${pkgs.bazelisk}/bin/bazelisk";
        "bazel.buildifierExecutable" = "${pkgs.bazel-buildtools}/bin/buildifier";
        "bazel.buildifierFixOnFormat" = true;
        "workbench.colorCustomizations" = {
          "[Catppuccin Mocha]" = {
            "editor.lineHighlightBackground" = "#45475a50";
            "editor.lineHighlightBorder" = "#00000000";
          };
          "[Catppuccin Latte]" = {
            "editor.lineHighlightBackground" = "#ccd0da50";
            "editor.lineHighlightBorder" = "#00000000";
          };
        };
      };
    };
  };
  home.packages = with pkgs; [
    gopls
  ];
}
