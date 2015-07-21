command_exists () {
      type "$1" &> /dev/null ;
      #echo "command $1 status $?"
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

docker_start() {
  # If I have boot2docker, go ahead and init it
  if hash boot2docker 2>/dev/null; then
    boot2docker init
    boot2docker start
    eval $(boot2docker shellinit)
  fi
}


