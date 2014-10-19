# make less more friendly for non-text input files, see lesspipe(1)
if which lesspipe.sh &> /dev/null; then
  eval "$(SHELL=/bin/sh lesspipe.sh)"
fi

emptytrash() {
  # Empty the Trash on all mounted volumes and the main HDD
  # Also, clear Apple’s System Logs to improve shell startup speed
  sudo rm -rfv /Volumes/*/.Trashes
  sudo rm -rfv ~/.Trash
  sudo rm -rfv /private/var/log/asl/*.asl
}

# Recursively delete `.DS_Store` files
alias dsclean="find . -type f -name '*.DS_Store' -ls -delete"

#Setup brew prefix.
which brew &> /dev/null && brew_prefix=$(brew --prefix)

# GRC colorizes nifty unix tools all over the place
if which grc &>/dev/null && [[ -n "${brew_prefix}" ]]; then
  source "${brew_prefix}/etc/grc.bashrc"
fi
