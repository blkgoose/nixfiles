function dotimes --argument times cmd
    for i in (seq $times)
        eval $cmd
    end
end
