if [[ "${PLATFORM}" == "darwin" ]]; then

  # Install Homebrew if it isn't already
  if ! which brew &> /dev/null; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  brew_installed=${HOME}/.brew_installed
  brew_cask_installed=${HOME}/.brew_cask_installed
  brew_taps=${HOME}/.brew_taps

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

    brew install "$(<"${brew_installed}")"
    brew cask install "$(<"${brew_cask_installed}")"
  }

  function sync-brew-installed {
    brew tap > "${brew_taps}"
    brew leaves > "${brew_installed}"
    brew cask list > "${brew_cask_installed}"
  }
fi
