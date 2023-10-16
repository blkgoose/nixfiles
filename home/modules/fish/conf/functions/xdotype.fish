function xdotype --argument text
    for i in (string split '' "$text")
        sleep 0.1
        xdotool key $i
    end
end
