{ ... }:

{
  /* Prune Rosetta JIT bytecode cache and macOS logs to prevent disk bloat. (mostly arm macs thingy)*
   * ref: https://github.com/nix-darwin/nix-darwin/pull/1165#issuecomment-2477157627                */
  launchd.daemons = {
    rosetta2-gc = {
      script = ''
        date
        exec /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -P -minsize 0 /System/Volumes/Data
      '';
      serviceConfig.StartInterval = 3600 * 2;
      serviceConfig.RunAtLoad = true;
      serviceConfig.StandardErrorPath = "/var/log/rosetta2-gc.log";
      serviceConfig.StandardOutPath = "/var/log/rosetta2-gc.log";
    };

    log-erase = {
      script = ''
        date
        log erase --all
      '';
      serviceConfig.StartInterval = 3600 * 24;
      serviceConfig.StandardErrorPath = "/var/log/uuidtext-gc.log";
      serviceConfig.StandardOutPath = "/var/log/uuidtext-gc.log";
    };

    fseventsd-reclaim = {
      script = ''
        killall -9 fseventsd
      '';
      serviceConfig.StartInterval = 3600;
    };
  };

  system.activationScripts.postActivation.text = ''
    printf "disabling spotlight indexing... "
    mdutil -i off -d / &> /dev/null
    mdutil -E / &> /dev/null
    echo "ok"
  '';
}
