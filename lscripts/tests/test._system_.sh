#!/bin/bash

## Copyright (c) 2024 mangalbhaskar. All Rights Reserved.
##__author__ = 'mangalbhaskar'
###----------------------------------------------------------
## test::shell script core/lsd-mod.system.sh module
###----------------------------------------------------------


# trap ctrlc_handler INT

# ## trap 'exit 0' INT or simply trap INT 
# function ctrlc_handler {
#   (>&2 echo -e "\e[0;101m CTRL-C pressed; Terminating..!\e[0m\n")
#   exit
# }


[[ "${BASH_SOURCE[0]}" != "${0}" ]] && echo "script ${BASH_SOURCE[0]} is being sourced ..." || echo "Script is a subshell"
[[ $0 != "$BASH_SOURCE" ]] && sourced=1 || sourced=0[1]


function test.lsd-mod.system.case-1() {
  lsd-mod.system.admin.restrict-cmds-for-sudo-user --user='blah' --group='dummy' --scripts_filepath=${_BZO__SCRIPTS}/lscripts-docker/lscripts/tests/test.echo.sh
}


function test.lsd-mod.system.main() {
  local LSCRIPTS=$( cd "$( dirname "${BASH_SOURCE[0]}")" && pwd )
  source ${LSCRIPTS}/../lscripts.config.sh
  
  export LSCRIPTS__LOG_LEVEL=7 ## DEBUG
  test.lsd-mod.system.case-1
}


test.lsd-mod.system.main
