# ${HOME}/.bashrc: executed by bash(1) for non-login shells.  If not running
# interactively, don't do anything
[[ -z "${PS1}" ]] && return

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

# Source my functions and start setting up my PATH
source_dir functions
path-prepend "${HOME}/bin"

# Source platform dependent stuff first to help with paths, etc.
source_platform

# Source the rest of the things.
source_dir topics

source ./.aws

docker_start() {
  # If I have boot2docker, go ahead and init it
  if hash boot2docker 2>/dev/null; then
    boot2docker init
    boot2docker start
    eval $(boot2docker shellinit)
  fi
}

#appending .local to path so that pip --user installs are found
export PATH=${PATH}:${HOME}/.local/bin
#THIS MUST BE AT THE END OF THE FILE FOR GVM TO WORK!!!
[[ -s "/Users/robert.smallwood/.gvm/bin/gvm-init.sh" ]] && source "/Users/robert.smallwood/.gvm/bin/gvm-init.sh"
