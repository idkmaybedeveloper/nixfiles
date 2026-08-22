{ ... }:

{
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      ApplePressAndHoldEnabled = false;
      AppleEnableSwipeNavigateWithScrolls = true;

      InitialKeyRepeat = 25;
      KeyRepeat = 5;

      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = true;
      NSTableViewDefaultSizeMode = 3;
      NSDocumentSaveNewDocumentsToCloud = false;

      "com.apple.keyboard.fnState" = false;
      "com.apple.sound.beep.feedback" = 1;
      "com.apple.trackpad.forceClick" = false;
      "com.apple.trackpad.scaling" = 3.0;
      "com.apple.springing.enabled" = true;
      "com.apple.springing.delay" = 0.5;
    };

    dock = {
      autohide = false;
      orientation = "left";
      tilesize = 34;
      largesize = 16;
      magnification = false;
      mineffect = "genie";
      minimize-to-application = true;
      show-recents = false;
      show-process-indicators = true;
      launchanim = true;
      showAppExposeGestureEnabled = false;
      showDesktopGestureEnabled = false;
      showLaunchpadGestureEnabled = true;
      showMissionControlGestureEnabled = true;
      wvous-br-corner = 1; # disabled
    };

    finder = {
      FXPreferredViewStyle = "icnv";
      QuitMenuItem = true;
      ShowHardDrivesOnDesktop = true;
      ShowExternalHardDrivesOnDesktop = true;
      ShowRemovableMediaOnDesktop = true;
      ShowMountedServersOnDesktop = true;
      FXRemoveOldTrashItems = true;
      FXEnableExtensionChangeWarning = false;
    };

    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = false;
      Dragging = false;
      DragLock = false;
      TrackpadFourFingerHorizSwipeGesture = 2;
      TrackpadFourFingerVertSwipeGesture = 2;
      TrackpadThreeFingerHorizSwipeGesture = 0;
      TrackpadThreeFingerVertSwipeGesture = 0;
      TrackpadRotate = false;
    };

    CustomUserPreferences = {
      # Changing these typically requires logging in/out to see the effects, but can be
      # force-reloaded with:
      # /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      #
      # apps that use +[NSFont userFixedPitchFontOfSize:]
      NSGlobalDomain = {
        NSFixedPitchFont = "Iosevka";
        NSFixedPitchFontSize = 13;
        AppleMenuBarVisibleInFullscreen = false;
        AppleReduceDesktopTinting = false;
      };

      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };

      "com.apple.screencapture" = {
        showsClicks = true;
      };

      "com.apple.finder" = {
        # PfAF = All My Files (legacy); not in nix-darwin NewWindowTarget enum
        NewWindowTarget = "PfAF";
        FXICloudDriveDesktop = false;
        FXICloudDriveDocuments = false;
      };

      "com.apple.loginwindow" = {
        TALLogoutSavesState = false;
      };

      "com.apple.Safari" = {
        IncludeDevelopMenu = true;
        AutoOpenSafeDownloads = false;
        WebKitDeveloperExtrasEnabledPreferenceKey = true;
      };
    };
  };
}
