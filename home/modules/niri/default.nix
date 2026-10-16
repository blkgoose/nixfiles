{ pkgs, lib, config, ... }: {
  imports = [ ./shell.nix ];

  config.home.packages = with pkgs; [
    niri
    xwayland-satellite
    wl-clipboard
    playerctl
    brightnessctl
    pulseaudio
    wayland-pipewire-idle-inhibit
    (writeShellScriptBin "niri-resize-v" ''
      focused=$(${pkgs.niri}/bin/niri msg -j focused-window)
      ws=$(echo "$focused" | ${pkgs.jq}/bin/jq '.workspace_id')
      pos=$(echo "$focused" | ${pkgs.jq}/bin/jq -c '.layout.pos_in_scrolling_layout // empty')
      [ -z "$pos" ] && exit 0
      col=$(echo "$pos" | ${pkgs.jq}/bin/jq '.[0]')
      tile=$(echo "$pos" | ${pkgs.jq}/bin/jq '.[1]')
      last=$(${pkgs.niri}/bin/niri msg -j windows | ${pkgs.jq}/bin/jq \
        --argjson ws "$ws" --argjson col "$col" \
        '[.[] | select(.workspace_id == $ws and .layout.pos_in_scrolling_layout[0] == $col) | .layout.pos_in_scrolling_layout[1]] | max')

      grow="+10%"
      shrink="-10%"
      if [ "$tile" = "$last" ] && [ "$last" -gt 1 ]; then
        [ "$1" = up ] && delta=$grow || delta=$shrink
      else
        [ "$1" = up ] && delta=$shrink || delta=$grow
      fi
      exec ${pkgs.niri}/bin/niri msg action set-window-height -- "$delta"
    '')
    (writeShellScriptBin "niri-scratchpad" ''
      niri=${pkgs.niri}/bin/niri
      jq=${pkgs.jq}/bin/jq

      win=$($niri msg -j windows | $jq -c --arg p "$1" \
        '[.[] | select((.app_id // "") | contains($p))][0] // empty')
      [ -z "$win" ] && exec "$2"

      id=$(echo "$win" | $jq '.id')
      if [ "$(echo "$win" | $jq '.is_focused')" = true ]; then
        exec $niri msg action move-window-to-workspace --window-id "$id" --focus false scratch
      fi

      current=$($niri msg -j workspaces | $jq '[.[] | select(.is_focused)][0].idx')
      $niri msg action move-window-to-workspace --window-id "$id" --focus false "$current"
      exec $niri msg action focus-window --id "$id"
    '')
  ];

  options.niri.extraConfig = lib.mkOption {
    type = lib.types.lines;
    default = "";
    description = "KDL appended to the niri config, e.g. extra binds, outputs or window rules.";
  };

  config.xdg.configFile."niri/config.kdl".text =
    builtins.readFile ./config.kdl + config.niri.extraConfig;
}
