{ ... }: {
  programs.git = {
    enable = true;

    ignores = [ ".direnv/" "mutagen.yaml.lock" ];

    aliases = {
      lg =
        "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ad)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'";
      s = "status -sb";
      unstage = "reset HEAD --";
      yolo = "push --force-with-lease";
      fap = "fetch --all --prune";
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
