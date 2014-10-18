if [[ "${PLATFORM}" == "darwin" ]]; then

  # Install Homebrew if it isn't already
  if ! which brew &> /dev/null; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  brew_formulas=${HOME}/.config/brew/formulas
  brew_casks=${HOME}/.config/brew/casks
  brew_taps=${HOME}/.config/brew/taps

  # Stuff for brew.
  path-prepend /usr/local/bin
  path-append /usr/local/sbin

  # Use GNU userland.
  path-prepend /usr/local/opt/coreutils/libexec/gnubin
  path-prepend /usr/local/opt/coreutils/libexec/gnuman MANPATH

  function sync-brew {
    while read -u 3 tap; do
      brew tap "${tap}"
    done 3< "${brew_taps}"

    brew install "$(<"${brew_formulas}")"
    brew cask install "$(<"${brew_casks}")"
  }

  function sync-brew-installed {
    brew tap > "${brew_taps}"
    brew leaves > "${brew_formulas}"
    brew cask list > "${brew_casks}"

    (
      homeshick cd bashrc
      git difftool -- "$(readlink "${brew_taps}")"
      git difftool -- "$(readlink "${brew_formulas}")"
      git difftool -- "$(readlink "${brew_casks}")"
    )
  }
fi
