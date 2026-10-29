{ config, inputs, lib, pkgs, ... }:
let
  source = builtins.fromJSON (builtins.readFile ./source.json);
in
{
  sops.secrets.ida-netrc = {
    sopsFile = ../../../../secrets/ida.yaml;
    key = "netrc";
    mode = "0400";
    owner = "root";
  };

  nix.settings.netrc-file = config.sops.secrets.ida-netrc.path;

  nixpkgs.overlays = [
    inputs.ida-pro-overlay.overlays.default
    (final: prev: {
      ida-pro = prev.ida-pro.overrideAttrs (old: let
        pythonForIda = final.python313.withPackages (ps: [ ps.rpyc ]);
      in {
        inherit (source) version;
        src = builtins.derivation {
          inherit (source) name url;
          builder = "builtin:fetchurl";
          system = "builtin";
          outputHashMode = "flat";
          outputHashAlgo = "sha256";
          outputHash = if source.hash == null then throw "set the installer hash in ida/source.json" else source.hash;
          preferLocalBuild = true;
        };
        installPhase =
          let
            marker = "addAutoPatchelfSearchPath $IDADIR";
            pluginPath = "--prefix QT_PLUGIN_PATH : $IDADIR/plugins/platforms";
          in
          assert lib.assertMsg (lib.hasInfix marker old.installPhase) "ida-pro installPhase changed";
          assert lib.assertMsg (lib.hasInfix pluginPath old.installPhase) "ida-pro qt wrapper changed";
          lib.replaceStrings [ marker pluginPath ] [ ''
            pushd "$IDADIR"
            ${final.python3}/bin/python3 ${./if_you_think_you_know_the_answer_dont_ask_me.py} --oneshot
            popd
            ${marker}
          '' ''
            --set QT_PLUGIN_PATH "$IDADIR/plugins" \
                --set QT_QPA_PLATFORM_PLUGIN_PATH "$IDADIR/plugins/platforms"'' ] old.installPhase;
        postFixup = (old.postFixup or "") + ''
          unlink "$out/bin/ida"
          cat > "$out/bin/ida" <<EOF
          #!${final.runtimeShell}
          set -e
          "$out/opt/idapyswitch" --force-path "${pythonForIda}/lib/libpython3.13.so.1.0"
          export PYTHONHOME="${pythonForIda}"
          export IDAPYTHON_VENV_EXECUTABLE="\''${IDAPYTHON_VENV_EXECUTABLE:-\$HOME/.idapro/venv/bin/python}"
          export PYTHONPATH="\$(dirname "\$(dirname "\$IDAPYTHON_VENV_EXECUTABLE")")/lib/python3.13/site-packages\''${PYTHONPATH:+:\$PYTHONPATH}"
          exec "$out/opt/ida" "\$@"
          EOF
          chmod +x "$out/bin/ida"
        '';
      });
    })
  ];

  environment.systemPackages = lib.optional (source.hash != null) pkgs.ida-pro;
  environment.sessionVariables = lib.optionalAttrs (source.hash != null) {
    HCLI_CURRENT_IDA_INSTALL_DIR = "${pkgs.ida-pro}/opt";
    IDAPYTHON_VENV_EXECUTABLE = "$HOME/.idapro/venv/bin/python";
  };
}
