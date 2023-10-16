function __make_targets
    make -qp \
    | awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ {split($1,A,/ /);for(i in A)print A[i]}' \
    | sort -u
end

complete -c make -a '(__make_targets)' -f
