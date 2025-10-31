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
      import XMonad.Layout.WindowArranger
      import XMonad.Layout.NoBorders

      import XMonad.Util.Loggers
      import XMonad.Hooks.DynamicLog
      import XMonad.Hooks.StatusBar
      import XMonad.Hooks.StatusBar.PP

      import XMonad.Actions.CycleWS

      import XMonad.Util.NamedScratchpad

      import Data.List (isInfixOf)

      spacing' gap =
          spacingRaw False
          (Border 0 gap 0 gap) True
          (Border gap 0 gap 0) True

      scratchpads =
          [ NS "slack" "slack" (c ~? "app.slack.com__client") nonFloating
          , NS "youtrack" "youtrack" (c ~? "myjetbrains.com__youtrack_agiles") nonFloating
          , NS "notion" "notion" (c ~? "www.notion.so") nonFloating
          , NS "calendar" "calendar" (c ~? "calendar.google.com__calendar") nonFloating
          ] where
              c = stringProperty "WM_CLASS"
              q ~? x = fmap (x `isInfixOf`) q

      myConf = def { terminal = "alacritty"
                   , layoutHook = lessBorders OnlyFloat $ navigation $ (spacing' 10 $ Dwindle R CW 1 1.1)
                   , borderWidth = 4
                   , focusedBorderColor = "#B388FF"
                   , normalBorderColor = "#F5F5F5"
                   , modMask = mod4Mask
                   , manageHook = namedScratchpadManageHook scratchpads
                   }
                  `additionalKeys`
                  [ ((mod4Mask .|. controlMask, xK_c), spawn "${pkgs.autorandr}/bin/autorandr -c || ${pkgs.autorandr}/bin/autorandr clone-largest")
                  , ((mod4Mask, xK_i), spawn "systemctl suspend")
                  , ((mod4Mask, xK_Tab), toggleWS)
                  , ((mod4Mask, xK_p), spawn "${pkgs.rofi}/bin/rofi -show run")
                  , ((mod4Mask .|. shiftMask, xK_i), spawn "${pkgs.slock}/bin/slock")

                  , ((mod4Mask, xK_s), namedScratchpadAction scratchpads "slack")
                  , ((mod4Mask, xK_y), namedScratchpadAction scratchpads "youtrack")
                  , ((mod4Mask, xK_n), namedScratchpadAction scratchpads "notion")
                  , ((mod4Mask, xK_c), namedScratchpadAction scratchpads "calendar")
                  ]
                  ++ movement
                  ++ mediaKeys
                  ++ notifications

      navigation = configurableNavigation (navigateBrightness 0)

      notifications =
          [ ((mod4Mask, xK_m), spawn "${pkgs.dunst}/bin/dunstctl history-pop")
          , ((mod4Mask .|. shiftMask, xK_m), spawn "${pkgs.dunst}/bin/dunstctl close")
          , ((mod4Mask, xK_r), spawn "${pkgs.dunst}/bin/dunstctl context")
          ]

      mediaKeys =
          [ ((0, xF86XK_AudioLowerVolume), spawn "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%;")
          , ((0, xF86XK_AudioRaiseVolume), spawn "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%;")
          , ((shiftMask, xF86XK_AudioLowerVolume), spawn "${pkgs.playerctl}/bin/playerctl -p spotify volume 0.05-")
          , ((shiftMask, xF86XK_AudioRaiseVolume), spawn "${pkgs.playerctl}/bin/playerctl -p spotify volume 0.05+")
          , ((0, xF86XK_AudioMute), spawn "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle;")
          , ((0, xF86XK_AudioPlay), spawn "${pkgs.playerctl}/bin/playerctl play-pause")
          , ((0, xF86XK_AudioNext), spawn "${pkgs.playerctl}/bin/playerctl next")
          , ((0, xF86XK_AudioPrev), spawn "${pkgs.playerctl}/bin/playerctl previous")
          , ((0, xF86XK_MonBrightnessUp), spawn "${pkgs.light}/bin/light -A 10")
          , ((0, xF86XK_MonBrightnessDown), spawn "${pkgs.light}/bin/light -U 10")
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
          , ((mod4Mask .|. controlMask, xK_l), sendMessage Expand)
          , ((mod4Mask .|. controlMask, xK_h), sendMessage Shrink)
          ]

      xmobarProp' config =
          withEasySB (statusBarProp "xmobar" (pure xmobarPP')) (\_ -> (mod4Mask, xK_b)) config

      xmobarPP' = def
          { ppCurrent = purple
          , ppHidden = offwhite
          , ppOrder = \(ws:_:t:_) -> [ws, t]
          , ppTitle = lowwhite . shorten 30
          }
        where
          purple = xmobarColor purpleColor ""
          offwhite = xmobarColor offwhiteColor ""
          lowwhite = xmobarColor "#505050" ""
          red = xmobarColor "#FF5252" ""

      purpleColor, offwhiteColor :: String
      purpleColor = "#B388FF"
      offwhiteColor = "#F5F5F5"

      main :: IO ()
      main = xmonad $ ewmhFullscreen $ ewmh $ xmobarProp' $ myConf
    '';
  };
}
