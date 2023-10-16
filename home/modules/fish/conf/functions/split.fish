# Defined in /tmp/fish.VDTzEX/split.fish @ line 2
function split --description 'split input string into lines using separator' --argument separator
	sed -re "s/$separator/\n/g"
end
