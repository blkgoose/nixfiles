{ config, ... }: {
  programs.dank-material-shell = {
    settings = {
      barConfigs = [
        {
          attachToScreenEdge = false;
          autoHide = false;
          autoHideDelay = 250;
          autoHideStrict = false;
          barInsetPadding = -1;
          barLengthPadding = 0;
          batteryColorMode = "level";
          borderColor = "surfaceText";
          borderEnabled = false;
          borderOpacity = 1;
          borderThickness = 1;
          bottomGap = 0;
          centerWidgets = [
            "music"
            "clock"
            "weather"
          ];
          clickThrough = false;
          enabled = true;
          fontScale = 1;
          gothCornerRadiusOverride = false;
          gothCornerRadiusValue = 12;
          gothCornersEnabled = false;
          hoverPopoutDelay = 150;
          hoverPopouts = false;
          iconScale = 1;
          id = "default";
          innerPadding = 8;
          island = true;
          islandBatteryStyle = "solid";
          islandFloating = false;
          islandHomeClockDisplay = "both";
          islandHomeCompactTight = false;
          islandPalette = "default";
          islandSatelliteBackground = false;
          islandSatelliteGap = 48;
          islandSatelliteGothCorners = false;
          islandSatellitePosition = "edges";
          islandUseOverlayLayer = false;
          islandOverlayWhenActive = true;
          islandNotificationExpand = true;
          leftWidgets = [
            "launcherButton"
            "workspaceSwitcher"
            "focusedWindow"
          ];
          maximizeDetection = true;
          maximizeWidgetIcons = false;
          maximizeWidgetText = true;
          name = "Main Bar";
          noBackground = false;
          openOnOverview = false;
          popupGapsAuto = true;
          popupGapsManual = 4;
          position = 0;
          removeWidgetPadding = false;
          rightWidgets = [
            "systemTray"
            "clipboard"
            "cpuUsage"
            "memUsage"
            "notificationButton"
            "battery"
            "controlCenterButton"
          ];
          screenPreferences = [ "all" ];
          scrollEnabled = true;
          scrollXBehavior = "column";
          scrollYBehavior = "workspace";
          shadowColorMode = "default";
          shadowCustomColor = "#000000";
          shadowIntensity = 0;
          shadowOpacity = 60;
          showOnLastDisplay = true;
          showOnWindowsOpen = false;
          spacing = 4;
          squareCorners = false;
          transparency = 1;
          useOverlayLayer = false;
          visible = true;
          widgetOutlineColor = "primary";
          widgetOutlineEnabled = false;
          widgetOutlineOpacity = 1;
          widgetOutlineThickness = 1;
          widgetPadding = 8;
          widgetTransparency = 1;
        }
      ];
      blurEnabled = false;
      builtInPluginSettings = {
        dms_clipboard_search = {
          trigger = "cb";
        };
        dms_power = {
          trigger = "pw";
        };
        dms_qr_generator = {
          trigger = "qrg";
        };
        dms_settings_search = {
          trigger = "?";
        };
      };
      clockDateFormat = "d/M";
      clockFormat = "24h";
      configVersion = 18;
      controlCenterShowMicPercent = true;
      cornerRadius = 12;
      currentThemeCategory = "dynamic";
      currentThemeName = "dynamic";
      cursorSettings = {
        hyprland = {
          hideOnKeyPress = false;
          hideOnTouch = false;
          inactiveTimeout = 0;
        };
        mango = {
          cursorHideTimeout = 0;
        };
        niri = {
          hideAfterInactiveMs = 0;
          hideWhenTyping = true;
        };
        size = 24;
        theme = "Adwaita";
      };
      firstDayOfWeek = 1;
      iconThemeDark = "Papirus-Dark";
      iconThemeLight = "Papirus-Dark";
      launcherStyle = "island";
      launcherUseOverlayLayer = true;
      matugenScheme = "scheme-fidelity";
      mediaUseAlbumArtAccent = true;
      niriLayoutBorderSize = 3;
      niriLayoutRadiusOverride = 20;
      notificationSummaryFontSize = 18;
      notificationBodyFontSize = 16;
      notificationRules = [
        {
          action = "default";
          enabled = true;
          field = "appName";
          matchType = "exact";
          pattern = "Google Chrome";
          urgency = "normal";
        }
      ];
      osdAlwaysShowValue = true;
      osdMediaPlaybackEnabled = true;
      osdPosition = 4;
      osdPowerProfileEnabled = true;
      padHours12Hour = true;
      screenPreferences = {
        dock = [ "all" ];
        wallpaper = [ "all" ];
      };
      showOnLastDisplay = {
        dock = true;
      };
      showSeconds = true;
      spotlightBarShowModeChips = true;
      systemTrayIconTintMode = "monochrome";
      useAutoLocation = true;
    };

    session = {
      wallpaperPath = "${config.home.homeDirectory}/.local/share/wallpapers/wallpaper";
      themeModeAutoMode = "location";
      configVersion = 5;
    };
  };
}
