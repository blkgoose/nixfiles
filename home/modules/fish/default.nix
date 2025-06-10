{ pkgs, lib, ... }: {
  xdg.configFile."fish/completions/pnpm.fish".source = pkgs.writeText "pnpm" ''
    function _pnpm_completion
      set cmd (commandline -o)
      set cursor (commandline -C)
      set words (count $cmd)

      set completions (eval env DEBUG=\"" \"" COMP_CWORD=\""$words\"" COMP_LINE=\""$cmd \"" COMP_POINT=\""$cursor\"" SHELL=fish pnpm completion-server -- $cmd)

      if [ "$completions" = "__tabtab_complete_files__" ]
        set -l matches (commandline -ct)*
        if [ -n "$matches" ]
          __fish_complete_path (commandline -ct)
        end
      else
        for completion in $completions
          echo -e $completion
        end
      end
    end

    complete -f -d 'pnpm' -c pnpm -a "(_pnpm_completion)"
  '';

  programs.fish = {
    enable = true;

    shellInit = ''
      eval (ssh-agent -c) > /dev/null
    '';

    shellAbbrs = {
      gd = "git diff";
      g = "git";
      gp = "git push";
      gs = "git s";
      ga = "git add";
      gdc = "git diff --cached";
    };

    shellAliases = {
      unp = "${pkgs.unp}/bin/unp --smart";
      watch = "command watch -n0 --color";
    };

    functions = {
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
