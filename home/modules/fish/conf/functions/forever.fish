function forever
    set stuff $argv

    while true;
        fish -c "$stuff"
    end
end
