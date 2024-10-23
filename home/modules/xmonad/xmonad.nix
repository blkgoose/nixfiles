{ pkgs, ... }: {
  xsession.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    config = pkgs.writeText "xmonad-config" ''
      import XMonad
      import XMonad.Util.EZConfig (additionalKeys)
      import Data.Ratio
      import XMonad.Hooks.EwmhDesktops
      import XMonad.Actions.UpdatePointer (updatePointer)
      import XMonad.Util.Run
      import Graphics.X11.ExtraTypes.XF86

      import XMonad.Layout.Dwindle
      import XMonad.Layout.Spacing
      import XMonad.Layout.WindowNavigation

      import XMonad.Hooks.DynamicLog
      import XMonad.Hooks.StatusBar
      import XMonad.Hooks.StatusBar.PP

      import XMonad.Actions.CycleWS

      spacing' gap =
          spacingRaw False
          (Border 0 gap 0 gap) True
          (Border gap 0 gap 0) True

      myConf = def { terminal = "alacritty"
                   , layoutHook = windowNavigation $ (spacing' 10 $ Dwindle R CW 1.5 1.1)
                   , borderWidth = 3
                   , focusedBorderColor = "#B388FF"
                   , normalBorderColor = "#F5F5F5"
                   , modMask = mod4Mask
                   }
                  `additionalKeys`
                  [ ((mod4Mask, xK_c), spawn "${pkgs.autorandr}/bin/autorandr -c")
                  , ((mod4Mask, xK_i), spawn "systemctl suspend")
                  , ((mod4Mask, xK_Tab), toggleWS)
                  , ((mod4Mask, xK_p), spawn "${pkgs.rofi}/bin/rofi -show run")
                  ]
                  ++ movement
                  ++ mediaKeys
                  ++ notifications

      notifications =
          [ ((mod4Mask, xK_e), spawn "${pkgs.dunst}/bin/dunstctl history-pop")
          , ((mod4Mask, xK_w), spawn "${pkgs.dunst}/bin/dunstctl close")
          , ((mod4Mask, xK_r), spawn "${pkgs.dunst}/bin/dunstctl context")
          , ((0, xK_Caps_Lock), spawn "${pkgs.dunst}/bin/dunstctl set-paused toggle")
          ]

      mediaKeys =
          [ ((0, xF86XK_AudioLowerVolume), spawn "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%;")
          , ((0, xF86XK_AudioRaiseVolume), spawn "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%;")
          , ((0, xF86XK_AudioMute), spawn "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle;")
          , ((0, xF86XK_AudioPlay), spawn "${pkgs.playerctl}/bin/playerctl play-pause")
          , ((0, xF86XK_AudioNext), spawn "${pkgs.playerctl}/bin/playerctl next")
          , ((0, xF86XK_AudioPrev), spawn "${pkgs.playerctl}/bin/playerctl previous")
          , ((0, xF86XK_MonBrightnessUp), spawn "${pkgs.light}/bin/light -A 10")
          , ((0, xF86XK_MonBrightnessUp), spawn "${pkgs.light}/bin/light -U 10")
          ]

      movement =
          [ ((mod4Mask, xK_h), sendMessage $ Go L)
          , ((mod4Mask, xK_j), sendMessage $ Go D)
          , ((mod4Mask, xK_k), sendMessage $ Go U)
          , ((mod4Mask, xK_l), sendMessage $ Go R)
          , ((mod4Mask .|. shiftMask, xK_h), sendMessage $ Swap L)
          , ((mod4Mask .|. shiftMask, xK_j), sendMessage $ Swap D)
          , ((mod4Mask .|. shiftMask, xK_k), sendMessage $ Swap U)
          , ((mod4Mask .|. shiftMask, xK_l), sendMessage $ Swap R)
          ]

      main :: IO ()
      main = xmonad $ ewmhFullscreen $ ewmh $ xmobarProp $ myConf
    '';
  };
}
