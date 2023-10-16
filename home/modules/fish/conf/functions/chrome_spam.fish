function chrome_spam --argument tabnum times
    sleep 5;
    for i in (seq $times)
        echo "$i/$times"
        xdotool key shift+F5
        sleep 1
        xdotool key --repeat $tabnum --repeat-delay 1 Tab
        sleep 0.5
        xdotool key Enter
        sleep 3
        xdotool key alt+Left
    end
end
