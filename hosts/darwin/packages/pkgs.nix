{
  config,
  pkgs,
  lib,
  attic,
  ...
}:

let
  android = pkgs.androidenv.composeAndroidPackages {
    platformVersions = [
      "34"
      "35"
    ];
    buildToolsVersions = [
      "34.0.0"
      "35.0.0"
    ];
    includeNDK = false;
  };

  buildbuddy =
    pkgs.runCommand "buildbuddy"
      {
        # TODO: mb remove in future
        src = pkgs.fetchurl {
          url = "https://github.com/buildbuddy-io/bazel/releases/download/5.0.355/bazel-5.0.355-darwin-arm64";
          sha256 = "sha256-jeHnMQKmJ0DVeHysI7QV9DcoBAvwvnKxxjAw+LOnYxE=";
        };
      }
      ''
        mkdir -p $out/bin
        cp $src $out/bin/bb
        chmod +x $out/bin/bb
      '';

  google-repo = pkgs.runCommand "google-repo" { } ''
    mkdir -p $out/bin
    cp ${
      pkgs.fetchurl {
        url = "https://storage.googleapis.com/git-repo-downloads/repo";
        sha256 = "Ebxok+ngwJQPwcyVt1xkX5op/Kh52JzqqJik12Girdc=";
      }
    } $out/bin/repo
    chmod +x $out/bin/repo
  '';

  depot-tools = pkgs.stdenv.mkDerivation {
    pname = "depot-tools";
    version = "unstable-2026-06-04";

    src = pkgs.fetchgit {
      url = "https://chromium.googlesource.com/chromium/tools/depot_tools.git";
      rev = "cefcb89275e0f7ff686f305d46cf568b986e888e";
      hash = "sha256-I4tUSpibdTbd/8cIA3Kn1wuJsVDX0Tn/zLiGlFxYcL0=";
    };

    dontBuild = true;

    installPhase = ''
      mkdir -p $out/share/depot_tools
      cp -r . $out/share/depot_tools/
    '';
  };

  composer-no-license = pkgs.symlinkJoin {
    name = "composer-no-license";
    paths = [ pkgs.phpPackages.composer ];
    postBuild = ''
      rm -f $out/LICENSE
    '';
  };

in

{
  home.packages = with pkgs; [
    git
    git-lfs
    late-sh
    pinentry-curses # gpg signing deps
    micro
    gnupg
    coreutils
    fish
    tmux
    jq
    ncdu
    fzf
    bat
    cmatrix
    fastfetch
    binwalk
    eza
    nixfmt
    rustscan
    nmap
    htop
    gh
    go
    btop
    ripgrep
    duf
    dotnet-sdk_10
    # dotnet-sdk_9
    # dotnet-sdk_7
    openssh
    android-tools
    android.androidsdk
    # android.android-ndk
    ffmpeg-full
    watch
    curl
    hyfetch
    aria2
    uv
    pwgen
    wget
    hexfiend
    cmake
    pv
    nodejs
    pnpm
    deno
    gitoxide
    pkg-config
    #openssl
    libressl
    # gcc
    gradle
    transmission_4
    scrcpy
    jadx
    apktool
    ssh-audit
    virt-manager
    bmake
    ncurses
    platformio
    python3Packages.pip
    gnumake
    zlib
    xz
    lzo
    sasquatch
    mtr
    hping
    asn
    rustc
    cargo
    ninja
    lld
    # pkgs.pkgsCross.gnu64.stdenv.cc
    upx
    zig
    wimlib
    libiconv
    exiftool
    nuget
    bison
    q
    maven
    gzdoom
    iamb
    nim
    nimble
    ripdrag
    yarn
    cocoapods
    devbox
    cacert
    qemu
    age
    sops
    ruff
    direnv
    presenterm
    google-repo
    protobuf
    cpio
    gdb
    graphviz
    ruby
    libyaml
    yasm
    xorriso
    flutter
    mitmproxy
    hugo
    mercurialFull
    unrar
    quickjs
    rustfmt
    grc
    nix-your-shell
    attic.packages.${pkgs.system}.attic-client
    minisign
    tree
    catgirl
    spleen
    iosevka-bin
    kubectl
    protoc-gen-go
    protoc-gen-go-grpc
    zmap
    zgrab2
    # trezor-agent
    nghttp2
    libnghttp2
    wrk
    caddy
    php
    composer-no-license
    # ^ wheelchair
    #   > pkgs.buildEnv error: two given paths contain a conflicting subpath:
    #   >   `/nix/store/0cqzcp9dl281hd10gx46v9yh49mc2afh-composer-2.8.12/LICENSE' and
    #   >   `/nix/store/r0hj2za0976pv0m5drk3vlxg951a0r8g-flutter-wrapped-3.38.3-sdk-links/LICENSE'
    libsodium
    #bazel
    bazelisk
    angie
    dpkg
    pfetch
    hyfetch
    gtest
    ghidra
    ghidra-extensions.wasm
    # msbuild
    github-linguist
    fd
    garble
    ldid
    libirecovery
    gvfs
    #mpv
    #gomobile
    sapling
    jujutsu
    emscripten
    pixman
    subversion
    nasm
    ant
    buck2
    virt-manager
    virt-viewer
    httpstat
    libimobiledevice
    usbmuxd
    k9s
    bun
    reuse
    amfora
    gleam
    just
    sshfs
    rust-analyzer
    stgit
    colima
    buildbuddy
    forgejo-cli
    #nixd
    nil
    helium
    materialgram
    rclone
    packer
    ostui
    flashrom
    ocamlPackages.ocaml-lsp
    ilspycmd
  ];

  home.file.".android-sdk".source = "${android.androidsdk}/libexec/android-sdk";

  home.sessionPath = [ "${config.home.homeDirectory}/.cache/depot_tools" ];

  home.activation.syncDepotTools = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    _store="${depot-tools}/share/depot_tools"
    _cache="$HOME/.cache/depot_tools"
    if [ ! -f "$_cache/.nix-stamp" ] || [ "$_store/cipd" -nt "$_cache/.nix-stamp" ]; then
      $DRY_RUN_CMD echo "[depot_tools] syncing to $_cache"
      $DRY_RUN_CMD mkdir -p "$_cache"
      $DRY_RUN_CMD cp -r "$_store/." "$_cache/"
      $DRY_RUN_CMD chmod -R u+w "$_cache"
      $DRY_RUN_CMD touch "$_cache/.nix-stamp"
    fi
  '';

  home.sessionVariables = {
    ANDROID_HOME = "${config.home.homeDirectory}/.android-sdk";
    ANDROID_SDK_ROOT = "${config.home.homeDirectory}/.android-sdk";
    DEPOT_TOOLS_UPDATE = "0";
    DEPOT_TOOLS_METRICS = "0";
  };
}
