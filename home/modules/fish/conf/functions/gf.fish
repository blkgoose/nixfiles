# Defined in /tmp/fish.prFkaP/gf.fish @ line 2
function gf --description 'list git folders in the subpath' --argument path
	set -q path[1]; or set path '.'

	find "$path" -iname '.git' -exec dirname {} ';'
end
