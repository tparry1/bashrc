# Set some super basic stuff
export PATH="${HOME}/bin:${PATH}"
export EDITOR="vim"
export VISUAL="${EDITOR}"
export LANG=en_US.UTF-8

source ~/.bashrc

#THIS MUST BE AT THE END OF THE FILE FOR GVM TO WORK!!!
[[ -s "/Users/douglas.borg/.gvm/bin/gvm-init.sh" ]] && source "/Users/douglas.borg/.gvm/bin/gvm-init.sh"
