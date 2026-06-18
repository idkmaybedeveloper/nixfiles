{ pkgs-2411, ... }:

{
  nix = {
    package = pkgs-2411.nix;

    settings = {
      extra-experimental-features = [
        "nix-command"
        "flakes"
      ];
      extra-substituters = [
        "https://cache.wejust.rest/labs"
        "https://shit.cuddles.rs/nixos"
      ];
      extra-trusted-public-keys = [
        "labs:1+w3w/rjRYzPhQals2BIspD0DZSyNmCP+dD76gGQPGU="
        "shit.cuddles.rs:HQ4GqwV3aPbneoDdl4diqMcRjmusLqtQkETdebH62sk="
      ];

      cores = 4;
      max-jobs = 2;

      max-silent-time = 7200;
      timeout = 43200;

      system-features = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "x86_64-darwin"
      ];
    };

    gc = {
      automatic = true;
      interval = [
        { Minute = 15; }
        { Minute = 45; }
      ];
      options = "--max-freed $(df -k /nix/store | awk 'NR==2 {available=$4; required=80*1024*1024; to_free=required-available; printf \"%.0d\", to_free*1024}')";
    };
  };
}
