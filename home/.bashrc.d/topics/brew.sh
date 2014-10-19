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

  sync-brew() {
    brew doctor

    while read tap <&3; do
      brew tap "${tap}"
    done 3< "${brew_taps}"

    while read formula <&3; do
      brew install "${formula}"
    done 3< "${brew_formulas}"

    while read cask <&3; do
      brew cask install "${cask}"
    done 3< "${brew_casks}"

    brew linkapps
    brew cleanup
    brew prune
  }

  sync-brew-installed() {
    brew tap > "${brew_taps}"
    brew leaves > "${brew_formulas}"
    brew cask list > "${brew_casks}"

    (
      homeshick cd bashrc
      git difftool -- "$(readlink "${brew_taps}")"
      git difftool -- "$(readlink "${brew_formulas}")"
      git difftool -- "$(readlink "${brew_casks}")"
      git commit -av
    )
  }
fi
