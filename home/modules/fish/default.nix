{ pkgs, lib, ... }:
let
  plugin = repo:
    { rev ? "master", sha256 ? "", subPath ? "" }:
    let
      _repo = lib.strings.splitString "/" repo;
      owner = builtins.elemAt _repo 0;
      name = builtins.elemAt _repo 1;
      src = pkgs.fetchFromGitHub {
        owner = owner;
        repo = name;
        rev = rev;
        sha256 = sha256;
      } + subPath;
    in {
      name = repo + subPath;
      src = assert builtins.pathExists src; src;
    };
in {
  imports = [ ./commit-message.nix ];

  programs.fish = {
    enable = true;

    shellInit = ''
      eval (direnv hook fish)
      eval (ssh-agent -c) > /dev/null
    '';

    plugins = [
      (plugin "jorgebucaran/fisher" {
        sha256 = "e8gIaVbuUzTwKtuMPNXBT5STeddYqQegduWBtURLT3M=";
      })
    ];

    shellAbbrs = {
      gd = "git diff";
      g = "git";
      gp = "git push";
      gs = "git s";
      ga = "git add";
      gdc = "git diff --cached";
      gc = { function = "__ai_generated_commit"; };
    };

    shellAliases = {
      unp = "${pkgs.unp}/bin/unp --smart";
      watch = "command watch -n0 --color";
    };

    functions = {
      __ai_generated_commit = {
        body =
          ''echo "git commit -m '"(git diff --cached | commit-generator)"'"'';
      };

      foreach = {
        body = "xargs -I'{}' fish -c $fun";
        description = "run function on every argument ({})";
        argumentNames = [ "fun" ];
      };

      forever = {
        body = ''
          set stuff $argv

          while true;
              fish -c "$stuff"
          end
        '';
        description = "repeats action forever";
      };

      retry = {
        body = ''
          set stuff $argv
          set counter 0

          while true;
              echo "try: $counter"
              fish -c "$stuff"
              if [ $status = 0 ]
                  ${pkgs.dunst}/bin/dunstify "retry" "completed: $stuff"
              break
              end
              set counter (math $counter + 1)
              sleep 1
          end
        '';
        description = "retries action till exit = 0";
      };

      dotimes = {
        body = ''
          for i in (seq $times)
              eval $cmd
          end
        '';
        description = "repeats action N times";
        argumentNames = [ "times" ];
      };

      fish_prompt = ''
        set s $status

        switch "$USER"
            case root toor
                set suffix '#'
            case '*'
                set suffix '$'
        end

        set nix_shell (
            if test -n "$IN_NIX_SHELL"
              echo (set_color cyan)"dev|"(set_color normal)
            end
        )

        echo -n -s "$nix_shell""[$s] " (set_color green)(basename (pwd))(set_color normal)" $suffix "
      '';

      fish_right_prompt = ''
        set alert_time 5000
        if test $CMD_DURATION
            if test $CMD_DURATION -gt $alert_time
                set seconds (math --scale 0 $CMD_DURATION / 1000)
                set hours (math --scale 0 $seconds / 3600); set seconds (math $seconds - $hours x 3600)
                set minutes (math --scale 0 $seconds / 60); set seconds (math $seconds - $minutes x 60)
                echo -n "took: "
                if test $hours -gt 0
                    echo -n "$hours hour"
                    if test $hours -ge 2
                        echo -n "s"
                    end
                    echo -n " "
                end
                if test $minutes -gt 0
                    echo -n "$minutes minute"
                    if test $minutes -ge 2
                        echo -n "s"
                    end
                    echo -n " "
                end
                echo -n "$seconds seconds"
                set -x CMD_DURATION 0
            end
        end
      '';

      fish_greeting = "";
    };
  };
}
