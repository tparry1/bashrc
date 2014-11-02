export HOMESICK="${HOME}/.homesick/repos"
export HOMESHICK="${HOMESICK}/homeshick"

# Use homeshick to manage my dotfiles repos.
source "${HOMESHICK}/homeshick.sh"

# My homesick repos
HOMESICK_REPOS=( "dougborg/bashrc" )
command -v vim &>- && HOMESICK_REPOS+=( "dougborg/vimrc" )
command -v atom &>- && HOMESICK_REPOS+=( "dougborg/atomrc" )

export HOMESICK_REPOS="${HOMESICK_REPOS[@]}"

# Shared dirs we should create first so homeshick repos don't mangle eachother:
export HOMESICK_MKDIRS=( "${HOME}/.ssh \
                        ${HOME}/.vim \
                        ${HOME}/bin " )

updateplatform() {
  case "${PLATFORM}" in
    darwin)
      # Update all teh OSX things.
      sudo softwareupdate -i -a
      if command -v brew &>-; then
        brew update
        brew upgrade
        brew cleanup
        brew cask update
        brew cask cleanup
      fi
    ;;

    linux)
      # Update all teh Linux things.
      command -v apt-get &>- && sudo apt-get update && sudo apt-get upgrade
      command -v yum &>- && sudo yum update && sudo yum upgrade
    ;;

    *)
      echo "I don't know how to update all teh things on ${PLATFORM}." >&2
    ;;
  esac
  command -v npm &>- && npm install npm@latest -g && npm update -g
  command -v gem &>- && sudo gem update
}

updatehome() {
  # Make sure git works - we're gonna need it!
  if ! command -v git &>-; then
    echo "git isn't installed or isn't functional." >&2
    return 1
  fi

  # Initialize homesick if needed.
  if [[ ! -d "${HOMESHICK}" ]]; then
    git clone git://github.com/andsens/homeshick.git "${HOMESHICK}"
  fi

  source "${HOMESHICK}/homeshick.sh"

  local dir
  for dir in "${HOMESICK_MKDIRS[@]}"; do
    if [[ ! -d ${dir} ]]; then
      echo "Creating ${dir}."
      mkdir -p "${dir}"
    else
      echo "${dir} exists."
    fi
  done

  for repo in ${HOMESICK_REPOS}; do
    homeshick --batch clone "${repo}";
  done

  # Update homesick repos.
  homeshick --batch pull
  homeshick --force link

  # Clean up any broken links:
  find "${HOME}" -type l -exec test ! -e {} \; -delete

  source "${HOME}/.bashrc"

  # Update vim configurations
  [[ -e "${HOME}/.vim/makefile" ]] && ( cd "${HOME}/.vim"; make install )

  # Sync atom packages
  command -v apm &>- && ( cd "${HOME}/.atom"; ./sync-atom )


updateall() {
  updateplatform
  updatehome
}

ssh-init-home() {
  local target=${1}

  ssh-copy-id "${target}"
  ssh -At "${target}" bash <<EOF
    export HOMESICK="\${HOME}/.homesick/repos"
    export HOMESHICK="\${HOMESICK}/homeshick"
    export HOMESICK_REPOS="${HOMESICK_REPOS}"
    export HOMESICK_MKDIRS="${HOMESICK_MKDIRS}"
    $(declare -f updatehome)
    updatehome
EOF
}
