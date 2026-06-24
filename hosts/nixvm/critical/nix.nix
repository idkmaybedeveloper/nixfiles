{
  nix.settings.substituters = [
    "https://shit.cuddles.rs/nixos"
    "https://cache.wejust.rest/labs"
    "https://cache.nixos.org"
  ];
  nix.settings.trusted-public-keys = [
    "shit.cuddles.rs:HQ4GqwV3aPbneoDdl4diqMcRjmusLqtQkETdebH62sk="
    "labs:1+w3w/rjRYzPhQals2BIspD0DZSyNmCP+dD76gGQPGU="
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];

  nix.buildMachines = [
    {
      hostName = "localhost";
      protocol = null;
      system = "x86_64-linux";
      supportedFeatures = [
        "kvm"
        "nixos-test"
        "big-parallel"
        "benchmark"
      ];
      maxJobs = 8;
    }
    {
      hostName = "macvm";
      system = "x86_64-darwin";
      sshUser = "root";
      sshKey = "/var/lib/hydra/queue-runner/keys/macvm";
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
      ];
      maxJobs = 4;
    }
  ];
}
