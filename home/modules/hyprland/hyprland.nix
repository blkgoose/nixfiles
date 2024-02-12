{ pkgs, ... }:
let
  conf = pkgs.writeText "hyprland" ''
    monitor=,preferred,auto,auto,bitdepth, 8

    exec-once=systemctl --user start waybar
    exec-once=dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
    exec-once=hyprpaper &

    env = XCURSOR_SIZE,24

    input {
        kb_layout = us
        kb_variant =
        kb_model =
        kb_options = compose:ralt,caps:none
        kb_rules =

        follow_mouse = 1

        touchpad {
            natural_scroll = no
        }

        sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
    }

    general {
        gaps_in = 5
        gaps_out = 20
        border_size = 2
        col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
        col.inactive_border = rgba(595959aa)

        layout = dwindle

        allow_tearing = false
    }

    decoration {
        rounding = 10

        blur {
            enabled = true
            size = 3
            passes = 1
        }

        drop_shadow = yes
        shadow_range = 4
        shadow_render_power = 3
        col.shadow = rgba(1a1a1aee)
    }

    animations {
        enabled = yes

        bezier = myBezier, 0.05, 0.9, 0.1, 1.05

        animation = windows, 1, 7, myBezier
        animation = windowsOut, 1, 7, default, popin 80%
        animation = border, 1, 10, default
        animation = borderangle, 1, 8, default
        animation = fade, 1, 7, default
        animation = workspaces, 1, 6, default
    }

    dwindle {
        pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = yes # you probably want this
    }

    master {
        new_is_master = true
    }

    gestures {
        workspace_swipe = off
    }

    misc {
        force_default_wallpaper = 0
    }

    device:epic-mouse-v1 {
        sensitivity = -0.5
    }

    binds {
        allow_workspace_cycles = yes
    }

    $terminal = alacritty

    $mainMod = SUPER

    # base binds
    bind = $mainMod SHIFT, RETURN, exec, $terminal
    bind = $mainMod SHIFT, C, killactive, 
    bind = $mainMod, V, togglefloating, 
    bind = $mainMod, P, exec, wofi --show run
    bind = $mainMod, SPACE, pseudo, # dwindle
    bind = $mainMod, RETURN, togglesplit, # dwindle

    # focus
    bind = $mainMod, h, movefocus, l
    bind = $mainMod, l, movefocus, r
    bind = $mainMod, k, movefocus, u
    bind = $mainMod, j, movefocus, d

    # move
    bind = $mainMod SHIFT, h, movewindow, l
    bind = $mainMod SHIFT, l, movewindow, r
    bind = $mainMod SHIFT, k, movewindow, u
    bind = $mainMod SHIFT, j, movewindow, d

    # resize
    binde = $mainMod CONTROL, h, resizeactive, -50 0
    binde = $mainMod CONTROL, l, resizeactive, 50 0
    binde = $mainMod CONTROL, k, resizeactive, 0 -50
    binde = $mainMod CONTROL, j, resizeactive, 0 50

    # workspace
    bind = $mainMod, 1, workspace, 1
    bind = $mainMod, 2, workspace, 2
    bind = $mainMod, 3, workspace, 3
    bind = $mainMod, 4, workspace, 4
    bind = $mainMod, 5, workspace, 5
    bind = $mainMod, 6, workspace, 6
    bind = $mainMod, 7, workspace, 7
    bind = $mainMod, 8, workspace, 8
    bind = $mainMod, 9, workspace, 9
    bind = $mainMod, 0, workspace, 10
    bind = $mainMod SHIFT, 1, movetoworkspace, 1
    bind = $mainMod SHIFT, 2, movetoworkspace, 2
    bind = $mainMod SHIFT, 3, movetoworkspace, 3
    bind = $mainMod SHIFT, 4, movetoworkspace, 4
    bind = $mainMod SHIFT, 5, movetoworkspace, 5
    bind = $mainMod SHIFT, 6, movetoworkspace, 6
    bind = $mainMod SHIFT, 7, movetoworkspace, 7
    bind = $mainMod SHIFT, 8, movetoworkspace, 8
    bind = $mainMod SHIFT, 9, movetoworkspace, 9
    bind = $mainMod SHIFT, 0, movetoworkspace, 10
    bind = $mainMod, TAB, workspace, previous

    # mouse
    bindm = $mainMod, mouse:272, movewindow
    bindm = $mainMod, mouse:273, resizewindow

    # shortcuts
    bind = , xf86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next
    bind = , xf86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl prev
    bind = , xf86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause

    bind = $mainMod, e, exec, ${pkgs.dunst}/bin/dunstctl history-pop
    bind = $mainMod, w, exec, ${pkgs.dunst}/bin/dunstctl close
    bind = $mainMod, r, exec, ${pkgs.dunst}/bin/dunstctl context
  '';
in { home.file.".config/hypr/hyprland.conf".source = conf; }
