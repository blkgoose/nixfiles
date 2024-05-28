{ pkgs, config, ... }:
let
  gitleaks_config = fetchGit {
    url = "https://github.com/primait/appsec-automation";
    rev = "c0d314ae64303ab091d73034b987921703cf2950";
  } + "/sast/sast-image/gitleaks/custom-config.toml";
in {
  programs.git.extraConfig.core.hooksPath =
    "${config.xdg.configHome}/git/hooks/";

  xdg.configFile."git/hooks/pre-commit".source =
    pkgs.writers.writeBash "pre-commit" ''
      ${pkgs.gitleaks}/bin/gitleaks protect -c ${gitleaks_config} -v --staged --redact
    '';
}
