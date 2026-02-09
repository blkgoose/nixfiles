{ ... }: {
  programs.git = {
    enable = true;

    ignores = [ ".direnv/" "mutagen.yaml.lock" ];

    settings = {
      alias = {
        lg =
          "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ad)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'";
        s = "status -sb";
        unstage = "reset HEAD --";
        yolo = "push --force-with-lease";
        fap = "fetch --all --prune";
        reset-author = ''
          !git -c rebase.instructionFormat='%s%nexec GIT_COMMITTER_DATE="%cD" GIT_AUTHOR_DATE="%aD" git commit --amend --no-edit --reset-author' rebase -f'';
      };

      user = {
        name = "blkgoose";
        email = "alessio.biancone@gmail.com";
      };
      init = { defaultBranch = "master"; };
      credential.helper = "store";
      core = {
        editor = "vim";
        autocrlf = "input";
        filemode = false;
      };
      push = {
        followTags = true;
        autoSetupRemote = true;
      };
      diff.tool = "vim -d";
      difftool.prompt = false;
      merge.tool = "vim -d";
    };
  };
}
