{ pkgs, ... }:
let
  wrapNixGL = package:
    (pkgs.symlinkJoin {
      name = package.name;
      paths = [ package ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        for full_path in $out/bin/*; do
          f=$(basename $full_path)
          rm $out/bin/$f
          echo "#!${pkgs.runtimeShell}" > $out/bin/$f
          echo "exec ${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel ${package}/bin/$f" '"$@"' >> $out/bin/$f
          chmod +x $out/bin/$f
        done
      '';
    });

  picom = wrapNixGL pkgs.picom;
in {
  xdg.configFile."picom/picom.conf" = {
    text = ''
      vsync = true;
      backend = "glx";
      corner-radius = 10;
      round-borders = 1;
    '';
    onChange = "${pkgs.systemd}/bin/systemctl --user restart picom";
  };

  systemd.user.services."picom" = {
    Unit.Description = "Runs picom correctly";
    Service.ExecStart = "${picom}/bin/picom";
    Install.WantedBy = [ "graphical-session.target" ];

    Unit = {
      After = "graphical-session.target";
      PartOf = "graphical-session.target";
    };
  };

}
