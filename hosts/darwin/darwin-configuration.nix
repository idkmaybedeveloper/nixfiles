{
  config,
  pkgs,
  nix-homebrew,
  homebrew-core,
  homebrew-cask,
  homebrew-php,
  homebrew-microsoft,
  homebrew-blacktop,
  homebrew-fuse-t,
  homebrew-lain,
  homebrew-FelixKratz,
  ...
}:

{
  imports = [
    ./critical
    ./packages/pkgswheelchair.nix
    ./services/vivienne.nix
    nix-homebrew.darwinModules.nix-homebrew
  ];

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "lain";
    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "shivammathur/homebrew-php" = homebrew-php;
      "microsoft/homebrew-git" = homebrew-microsoft;
      "blacktop/homebrew-tap" = homebrew-blacktop;
      "lain/homebrew-tap" = homebrew-lain;
      "FelixKratz/homebrew-formulae" = homebrew-FelixKratz;
    };

    mutableTaps = false;
  };

  homebrew.taps = [
    "homebrew/homebrew-core"
    "homebrew/homebrew-cask"
    "shivammathur/php"
    "microsoft/git"
    "blacktop/homebrew-tap"
    "lain/homebrew-tap"
  ];
}
