# ${HOME}/.bashrc: executed by bash(1) for non-login shells.  If not running
# interactively, don't do anything
[[ -z "${PS1}" ]] && return

function source_platform {
  if [[ ${OS} =~ Windows ]]; then
    uname_flag='-o'
  else
    uname_flag='-s'
  fi

  PLATFORM=$(uname ${uname_flag})
  export PLATFORM=${PLATFORM,,}

  source "${HOME}/.bashrc.d/platform/${PLATFORM}.sh"
}

function source_dir {
  local dir=${HOME}/.bashrc.d/${1}

  if [[ -d ${dir} ]]; then
    while read dotd; do
      source "${dotd}"
    done 3< <(find "${dir}" -name '*.sh')
    unset dotd
  fi
}

# Source my functions and start setting up my PATH
source_dir functions
path-prepend "${HOME}/bin"

# Source platform dependent stuff first to help with paths, etc.
source_platform

# Source the rest of the things.
source_dir topics
