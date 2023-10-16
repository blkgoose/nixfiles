# Defined in /tmp/fish.BlkdXR/fish_right_prompt.fish @ line 2
function fish_right_prompt
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
end
