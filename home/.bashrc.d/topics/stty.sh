# Use ^X instead of ^S to stop control flow so I can reclaim ^S for forward
# common history search
case "${PLATFORM}" in
  darwin)
    stty -f /dev/tty -ixon || stty -f /dev/tty -ixon
    stty -f /dev/tty stop ^X || stty -f /dev/tty stop ^X
  ;;
  linux)
    stty -F /dev/tty -ixon || stty -f /dev/tty -ixon
    stty -F /dev/tty stop ^X || stty -f /dev/tty stop ^X  
  ;;
  *)
    echo "I'm not sure how to set up stty"
  ;;
esac
