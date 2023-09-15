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

myConf = def { terminal = "alacritty"
             , layoutHook = smartBorders $ ThreeColMid 1 (3/100) (1/2)
             , borderWidth = 2
             , modMask = mod4Mask
             }
            `additionalKeys`
            [
                ((mod4Mask, xK_o), spawn "echo $PATH > /home/alessio/path_out")
            ]

main = do
    xmonad =<< xmobar (ewmh . ewmhFullscreen $ myConf)
