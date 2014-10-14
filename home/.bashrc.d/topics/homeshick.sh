export HOMESICK="${HOME}/.homesick/repos"
export HOMESHICK="${HOMESICK}/homeshick"

# Use homeshick to manage my dotfiles repos.
source "${HOMESHICK}/homeshick.sh"

# My homesick repos
# @PERSONALIZE@
export HOMESICK_REPOS="dougborg/bashrc \
                       dougborg/vimrc \
                       dougborg/atomrc"

# Shared dirs we should create first so homeshick repos don't mangle eachother:
# @PERSONALIZE@
export HOMESICK_MKDIRS='~/{.ssh,.vim,bin}'
