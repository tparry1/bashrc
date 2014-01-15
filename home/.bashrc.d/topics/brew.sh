if [[ "${PLATFORM}" == "darwin" ]]; then
  brew_installed=${HOME}/.brew_installed
  brew_taps=${HOME}/.brew_taps

  # Stuff for brew.
  path-prepend /usr/local/bin
  path-append /usr/local/sbin

  # Use GNU userland.
  path-prepend /usr/local/opt/coreutils/libexec/gnubin
  path-prepend /usr/local/opt/coreutils/libexec/gnuman MANPATH

  function brew {
    # Create a wrapper for brew that keeps a list of installed brew packages up to
    # date.
    if command brew ${@}; then
      case ${1} in
        install|remove|rm|uninstall|tap)
         sync-brew-installed
        ;;
      esac
    fi
  }

  function sync-brew {
    command brew tap $(cat ${brew_taps})
    command brew install $(cat ${brew_installed})
  }

  function sync-brew-installed {
    command brew leaves > ${brew_installed}
    command brew tap > ${brew_taps}
  }
fi
