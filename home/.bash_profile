# Set some super basic stuff
export PATH="${HOME}/bin:${HOME}/.linuxbrew/bin:${PATH}"
export EDITOR="vim"
export VISUAL="${EDITOR}"
export LANG=en_US.UTF-8

source ~/.bashrc

#THIS MUST BE AT THE END OF THE FILE FOR GVM TO WORK!!!
[[ -s "/Users/robert.smallwood/.gvm/bin/gvm-init.sh" ]] && source "/Users/robert.smallwood/.gvm/bin/gvm-init.sh"
