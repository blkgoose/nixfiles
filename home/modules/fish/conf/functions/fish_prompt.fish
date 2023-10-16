# Defined in /tmp/fish.jFUIVS/fish_prompt.fish @ line 2
function fish_prompt
	switch "$USER"
        case root toor
            set suffix '#'
        case '*'
            set suffix '$'
    end

    echo -n -s "[$status] " (set_color green)(basename (pwd))(set_color normal)" $suffix "
end
