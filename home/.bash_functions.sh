#!/bin/sh

export HOMESICK="${HOME}/.homesick/repos"
export HOMESHICK="${HOMESICK}/homeshick"

# Use homeshick to manage my dotfiles repos.
if [[ -d "${HOMESHICK}" ]]; then
  source "${HOMESHICK}/homeshick.sh"
fi

# My homesick repos
HOMESICK_REPOS=( "git@github.com:rdsmallwood928/bashrc" )
command -v vim &> /dev/null && HOMESICK_REPOS+=( "git@github.com:rdsmallwood928/vimrc" )

export HOMESICK_REPOS="${HOMESICK_REPOS[@]}"

# Shared dirs we should create first so homeshick repos don't mangle eachother:
export HOMESICK_MKDIRS=( "${HOME}/.ssh"
                         "${HOME}/.vim"
                         "${HOME}/.tmux"
                         "${HOME}/bin" )

brew_formulas=${HOME}/.config/brew/formulas
brew_casks=${HOME}/.config/brew/casks
brew_taps=${HOME}/.config/brew/taps

command_exists () {
  type "$1" &> /dev/null;
}

source_platform() {
  if [[ ${OS} =~ Windows ]]; then
    uname_flag='-o'
  else
    uname_flag='-s'
  fi
  export PLATFORM=$(uname ${uname_flag} | tr '[:upper:]' '[:lower:]')
  source "${HOME}/.bashrc.d/platform/${PLATFORM}.sh"
}

source_dir() {
  local dir=${HOME}/.bashrc.d/${1}

  if [[ -d ${dir} ]]; then
    local dotd
    while read dotd <&3; do
      source "${dotd}"
    done 3< <(find "${dir}" -name '*.sh')
  fi
}

docker_stop() {
  if command_exists docker-machine; then
    if [[ $(docker-machine ls | grep dockerdaemon | wc -l) -gt "0" ]]; then
      echo "Stopping docker daemon"
      docker-machine stop dockerdaemon
    fi
  fi
}


docker_start() {
  # If I have boot2docker, go ahead and init it
  if command_exists docker-machine; then
    docker_stop
    if [[ $(docker-machine ls | grep dockerdaemon | wc -l) -eq "0" ]]; then
      echo "Creating new docker daemon..."
      docker-machine create --driver virtualbox dockerdaemon
    fi
    docker-machine start dockerdaemon
    eval $(docker-machine env dockerdaemon)
  fi
}

sync-brew (){
  if ! command -v brew >&/dev/null; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";
  fi;
  brew doctor;
  while read tap 0<&3; do
    brew tap "${tap}";
  done 3< "${brew_taps}";
  while read formula 0<&3; do
    brew install "${formula}";
  done 3< "${brew_formulas}";
  while read cask 0<&3; do
    brew cask install "${cask}";
  done 3< "${brew_casks}";
  brew linkapps;
  brew cleanup;
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

chug_brews() {
  sync-brew
  brew update
  brew upgrade
  brew cleanup
  brew cask update
  brew cask cleanup
}

updateplatform() {
  echo "This appears to be ${PLATFORM}"
  case "${PLATFORM}" in
    darwin)
      # Update all teh OSX things.
      sudo softwareupdate -i -a
      if command_exists brew; then
        chug_brews
      else
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        export PATH="{$PATH}:${HOME}/.linuxbrew/bin"
        chug_brews
      fi
    ;;

    linux)
      if command_exists brew; then
        chug_brews
      else
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/linuxbrew/go/install)"
        chug_brews
      fi
    ;;

    *)
      echo "I don't know how to update all teh things on ${PLATFORM}." >&2
    ;;
  esac
  eclim_setup
  command -v npm &> /dev/null && npm install npm@latest -g && npm update -g
  command -v gem &> /dev/null && sudo gem update
}

eclim_setup() {
  wget http://sourceforge.net/projects/eclim/files/eclim/2.5.0/eclim_2.5.0.jar
  java -Dvim.files=${HOME}/.vim -Declipse.home=${ECLIPSE_HOME} -jar eclim_2.5.0.jar install
  rm eclim_2.5.0.jar
}

completehomeupdate() {
  if ! command_exists git; then
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

  echo "update complete"
}

updatehome() {
  # Make sure git works - we're gonna need it!
  if command_exists updateclean; then
    updateclean
    curl -fsSL https://raw.githubusercontent.com/rdsmallwood928/bashrc/master/home/.bash_functions.sh > ${HOME}/.temp_func
    source ${HOME}/.temp_func
    rm ${HOME}/.temp_func
    echo "clean completed"
  fi
  completehomeupdate
}


updateall() {
  source_platform
  updateplatform
  updatehome
}

updateclean() {
  unset -f updateall
  unset -f updatehome
  unset -f updateplatform
  rm -rf ~/.homesick/repos/bashrc
  rm -rf ~/.homesick/repos/vimrc
}

starteclimd() {
  ${ECLIPSE_HOME}/eclimd &
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
