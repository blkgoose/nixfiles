{ pkgs, config, prima-appsec, ... }:
let
  gitleaks_config =
    "${prima-appsec}/sast/sast-image/gitleaks/custom-config.toml";
in {
  programs.git.extraConfig.core.hooksPath =
    "${config.xdg.configHome}/git/hooks/";

  xdg.configFile."git/hooks/pre-commit".source =
    pkgs.writers.writeBash "pre-commit" ''
      set -e

      PROJ_ROOT=$(git rev-parse --show-toplevel)
      HOOK_PATH=$PROJ_ROOT/.git/hooks/pre-commit

      ${pkgs.gitleaks}/bin/gitleaks protect -c ${gitleaks_config} -v --staged --redact

      if [ -e "$HOOK_PATH" ] && [ -x "$HOOK_PATH" ] ; then
        $HOOK_PATH "$@"
      else
        exit 0
      fi
    '';
}
