# Defined in /tmp/fish.VvRs4J/foreach.fish @ line 2
function foreach --description 'run function on every argument' --argument fun parallel
	xargs -I'{}' -P 1 fish -c $fun
end
