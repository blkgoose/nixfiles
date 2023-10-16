# Defined in /tmp/fish.JwZhZ0/funcdel.fish @ line 2
function funcdel
	if test -e ~/.config/fish/functions/$argv[1].fish
        rm ~/.config/fish/functions/$argv[1].fish
        echo 'Deleted function' $argv[1]
    else
        echo 'Function' $argv[1] 'not found'
    end
end
