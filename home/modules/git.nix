{ pkgs, lib, ... }:
let
  excludes = pkgs.writeText "excludes" ''
    mutagen.yml.lock
  '';
in {
  programs.git = {
    enable = true;

    aliases = {
      lg =
        "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ad)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'";
      s = "status -sb";
      unstage = "reset HEAD --";
      yolo = "push --force-with-lease";
      fap = "fetch --all --prune";
      spy =
        "!git for-each-ref --format='%(committerdate) %09 %(authorname) %09 %(refname)' | grep 'refs/remotes' | sed 's#refs/remotes/origin/##' | grep -v 'HEAD$' | sort -k5n -k2M -k3n -k4.1 -k4.2 -k4.3 | tac";
      spyname = "!git spy | sort -k7,8";
      branch-clean =
        "!git branch --merged | grep -vE 'master|develop|\\*' | xargs git branch -d";
      c = "!git diff --cached && git cz";
      create-branch = "!git checkout -b";
    };

    extraConfig = {
      user = {
        name = "blkgoose";
        email = "alessio.biancone@gmail.com";
      };
      init = { defaultBranch = "master"; };
      credential.helper = "store";
      core = {
        editor = "nvim";
        autocrlf = "input";
        filemode = false;
        excludesfile = "${excludes}";
      };
      push = {
        followTags = true;
        autoSetupRemote = true;
      };
      diff.tool = "vimdiff";
      difftool.prompt = false;
      merge.tool = "vimdiff";

    };
  };
}
