#!/bin/bash

# Install gvm if it is not there
if [[ ! -d "${HOME}/.gvm" ]]; then
  curl -s get.gvmtool.net | bash
fi

# Set up gvm if it exists.
[[ -s "/Users/dborg/.gvm/bin/gvm-init.sh" ]] && source "/Users/dborg/.gvm/bin/gvm-init.sh"
