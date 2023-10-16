# Defined in - @ line 1
function clip --description 'alias clip xclip -selection clipboard'
	xclip -selection clipboard $argv;
end
