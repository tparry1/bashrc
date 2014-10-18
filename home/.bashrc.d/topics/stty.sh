# Use ^X instead of ^S to stop control flow so I can reclaim ^S for forward
# common history search
if (( BASH_VERSINFO > 3 )); then
  stty -F /dev/tty -ixon
  stty -F /dev/tty stop ^X
fi
