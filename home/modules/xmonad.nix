{ pkgs, lib, ... }:
let
  mouse_move = "20";

  spotify_volume_control = pkgs.writers.writeBash "spotify_volume_control" ''
    inc="$1"

    spotify_id=$(\
        ${pkgs.wireplumber}/bin/wpctl status \
        | ${pkgs.gnused}/bin/sed -n -e '/Streams:/,$p' \
        | ${pkgs.gnused}/bin/sed '/^Video/q' \
        | ${pkgs.gnugrep}/bin/grep "\. spotify" \
        | ${pkgs.coreutils}/bin/cut -d. -f1 \
        | ${pkgs.gawk}/bin/gawk '{printf "%s\n", $1}'
    )

    function notify() {
        ${pkgs.dunst}/bin/dunstify \
            -a "volume:spotify" \
            -u low \
            -h string:x-dunst-stack-tag:spotify_volume \
            -i spotify \
            "$@"
    }

    # if spotify is not running, stop
    [[ -z "$spotify_id" ]] && {
        notify "not running"
        exit
    }

    # first client sets volume for all
    first_id=$(echo "$spotify_id" | ${pkgs.coreutils}/bin/head -1)
    ${pkgs.wireplumber}/bin/wpctl set-volume "$first_id" "$inc"
    volume_raw="$(${pkgs.wireplumber}/bin/wpctl get-volume "$first_id" \
        | ${pkgs.coreutils}/bin/cut -d: -f2 \
        | ${pkgs.findutils}/bin/xargs \
    )"
    volume="$(echo "$volume_raw" | ${pkgs.gawk}/bin/awk '{printf "%0.0f", $1*100}')"

    for sid in $spotify_id
    do
        ${pkgs.wireplumber}/bin/wpctl set-volume "$sid" "$volume_raw"
    done

    notify \
        -h int:value:"$volume" \
        "spotify: $volume%"
  '';

  brightness_controller = pkgs.writers.writeBash "brightness_notification" ''
    inc="$1"

    brightness="$(\
        ${pkgs.brightnessctl}/bin/brightnessctl s $inc \
        | ${pkgs.gnugrep}/bin/grep -oP '\d+' \
        | ${pkgs.coreutils}/bin/tail -n+2 \
        | ${pkgs.coreutils}/bin/head -1 
    )"

    ${pkgs.dunst}/bin/dunstify \
        -a "brightness" \
        -u low \
        -i display-brightness-symbolic \
        -h int:value:"$brightness" \
        -h string:x-dunst-stack-tag:brightness \
        "brightness: $brightness%"
  '';

  volume_controller = pkgs.writers.writeBash "volume_controller" ''
    inc="$1"

    if [[ $inc == "0" ]]; then
        ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle
    else
        ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ "$inc"
    fi

    volume="$(${pkgs.pulseaudio}/bin/pactl get-sink-volume @DEFAULT_SINK@ \
        | ${pkgs.gnugrep}/bin/grep -oP "(\d*)%" \
        | ${pkgs.coreutils}/bin/head -1 \
    )"
    mute="$(${pkgs.pulseaudio}/bin/pactl get-sink-mute @DEFAULT_SINK@ \
        | ${pkgs.gnugrep}/bin/grep -q "no" && echo "on" || echo "off"\
    )"

    function notify() {
        ${pkgs.dunst}/bin/dunstify \
            -a "volume" \
            -u low \
            -h string:x-dunst-stack-tag:volume \
            "$@"
    }

    if [[ "$volume" == 0 || "$mute" == "off" ]]; then
        notify \
            -i audio-volume-muted \
            -h int:value:"$volume" \
            "volume: muted"
    else
        notify \
            -i audio-volume-high \
            -h int:value:"$volume" \
            "volume: $volume"
    fi
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

                , ((0, xF86XK_AudioLowerVolume), spawn "${volume_controller} -5%")
                , ((0, xF86XK_AudioRaiseVolume), spawn "${volume_controller} +5%")
                , ((0, xF86XK_AudioMute), spawn "${volume_controller} 0")

                , ((shiftMask, xF86XK_AudioLowerVolume), spawn "${spotify_volume_control} 5%-")
                , ((shiftMask, xF86XK_AudioRaiseVolume), spawn "${spotify_volume_control} 5%+")

                , ((0, xF86XK_AudioPlay), spawn "${pkgs.playerctl}/bin/playerctl play-pause")
                , ((0, xF86XK_AudioNext), spawn "${pkgs.playerctl}/bin/playerctl next")
                , ((0, xF86XK_AudioPrev), spawn "${pkgs.playerctl}/bin/playerctl previous")

                , ((0, xF86XK_MonBrightnessUp), spawn "${brightness_controller} 10%+")
                , ((0, xF86XK_MonBrightnessDown), spawn "${brightness_controller} 10%-")

                , ((mod4Mask, xK_i), spawn "systemctl suspend")

                , ((mod1Mask, xK_h), spawn "${pkgs.xdotool}/bin/xdotool mousemove_relative -- -${mouse_move} 0")
                , ((mod1Mask, xK_j), spawn "${pkgs.xdotool}/bin/xdotool mousemove_relative -- 0 +${mouse_move}")
                , ((mod1Mask, xK_k), spawn "${pkgs.xdotool}/bin/xdotool mousemove_relative -- 0 -${mouse_move}")
                , ((mod1Mask, xK_l), spawn "${pkgs.xdotool}/bin/xdotool mousemove_relative -- +${mouse_move} 0")
                , ((mod1Mask .|. mod4Mask, xK_h), spawn "${pkgs.xdotool}/bin/xdotool click 1")
                , ((mod1Mask .|. mod4Mask, xK_l), spawn "${pkgs.xdotool}/bin/xdotool click 3")
                ]

    main = do
        xmonad =<< xmobar (ewmh . ewmhFullscreen $ myConf)
  '';
in { home.file.".config/xmonad/xmonad.hs".source = conf; }
