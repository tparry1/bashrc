# Use ^X instead of ^S to stop control flow so I can reclaim ^S for forward
# common history search
stty -f /dev/tty -ixon || stty -f /dev/tty -ixon
stty -f /dev/tty stop ^X || stty -f /dev/tty stop ^X
