# Defined in /tmp/fish.7glA9L/retry.fish @ line 2
function retry
	set stuff $argv
        set counter 0

        while true;
            echo "try: $counter"
            fish -c "$stuff"
            if [ $status = 0 ]
                notify-send "retry" "completed: $stuff"
                break
            end
            set counter (math $counter + 1)
            sleep 1
    end
end
