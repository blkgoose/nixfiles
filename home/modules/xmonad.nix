{ dots, pkgs, lib, ... }:
let
  spotify_volume_control = pkgs.writers.writeBashBin "spotify_volume_control" ''
    ${pkgs.dunst}/bin/dunstify -a "spotify_volume_control" "$@"
  '';

  brightness_notification =
    pkgs.writers.writeBashBin "brightness_notification" ''
      ${pkgs.dunst}/bin/dunstify -a "brightness_notification" "$@"
    '';

  volume_notification = pkgs.writers.writeBashBin "volume_notification" ''
    ${pkgs.dunst}/bin/dunstify -a "volume_notification" "$@"
  '';

  conf = pkgs.writeText "xmonad" ''
    import XMonad

    import XMonad.Util.EZConfig (additionalKeys)
    import XMonad.Util.Ungrab
    import XMonad.Layout.ThreeColumns
    import XMonad.Layout.NoBorders
    import XMonad.Hooks.EwmhDesktops
    import XMonad.Hooks.DynamicLog (xmobar)
    import XMonad.Hooks.StatusBar
    import XMonad.Hooks.StatusBar.PP
    import XMonad.Actions.UpdatePointer (updatePointer)
    import XMonad.Util.Run
    import Graphics.X11.ExtraTypes.XF86

    myConf = def { terminal = "alacritty"
                 , layoutHook = smartBorders $ ThreeColMid 1 (3/100) (1/2)
                 , borderWidth = 2
                 , modMask = mod4Mask
                 }
                `additionalKeys`
                [ ((mod4Mask, xK_c), spawn "autorandr -c")

                , ((mod4Mask, xK_e), spawn "${pkgs.dunst}/bin/dunstctl history-pop")
                , ((mod4Mask, xK_w), spawn "${pkgs.dunst}/bin/dunstctl close")
                , ((mod4Mask, xK_r), spawn "${pkgs.dunst}/bin/dunstctl context")
                , ((0, xK_Caps_Lock), spawn "${pkgs.dunst}/bin/dunstctl set-paused toggle")

                , ((0, xF86XK_AudioLowerVolume), spawn "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%; ${volume_notification}")
                , ((0, xF86XK_AudioRaiseVolume), spawn "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%; ${volume_notification}")
                , ((0, xF86XK_AudioMute), spawn "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle; ${volume_notification}")

                , ((shiftMask, xF86XK_AudioLowerVolume), spawn "${spotify_volume_control} 5%-")
                , ((shiftMask, xF86XK_AudioRaiseVolume), spawn "${spotify_volume_control} 5%+")

                , ((0, xF86XK_AudioPlay), spawn "${pkgs.playerctl}/bin/playerctl play-pause")
                , ((0, xF86XK_AudioNext), spawn "${pkgs.playerctl}/bin/playerctl next")
                , ((0, xF86XK_AudioPrev), spawn "${pkgs.playerctl}/bin/playerctl previous")

                , ((0, xF86XK_MonBrightnessUp), spawn "${pkgs.light}/bin/light -A 10; ${brightness_notification}")
                , ((0, xF86XK_MonBrightnessUp), spawn "${pkgs.light}/bin/light -U 10; ${brightness_notification}")

                , ((mod4Mask, xK_i), spawn "systemctl suspend")
                ]

    main = do
        xmonad =<< xmobar (ewmh . ewmhFullscreen $ myConf)
  '';
in { home.file.".config/xmonad/xmonad.hs".source = conf; }
