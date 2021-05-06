#!/bin/bash

## Copyright (c) 2021 mangalbhaskar. All Rights Reserved.
##__author__ = 'mangalbhaskar'
###----------------------------------------------------------
## test:: for shell script logging module
###----------------------------------------------------------


trap ctrlc_handler INT

## trap 'exit 0' INT or simply trap INT 
function ctrlc_handler {
  (>&2 echo -e "\e[0;101m CTRL-C pressed; Terminating..!\e[0m\n")
  exit
}


[[ "${BASH_SOURCE[0]}" != "${0}" ]] && echo "script ${BASH_SOURCE[0]} is being sourced ..." || echo "Script is a subshell"
[[ $0 != "$BASH_SOURCE" ]] && sourced=1 || sourced=0[1]


function test-1-case-1-argparse() {
  source ${LSCRIPTS}/../utils/argparse.sh "$@"
  echo "Total: $# should be equal to ${#args[@]} and args: ${args[@]}"

  local key
  for key in "${!args[@]}"; do
    [[ -n "${args[${key}]+1}" ]] && echo "${key} = ${args[${key}]}" || echo "Key does not exists: ${key}"
  done
}


function test-1-argparse() {
  local LSCRIPTS=$( cd "$( dirname "${BASH_SOURCE[0]}")" && pwd )
  source ${LSCRIPTS}/../lscripts.config.sh
  
  export _fio__LEVEL_=7 ## DEBUG
  test-1-case-1-argparse --user='blah' --group='dummy' --uid=1111 --gid=0000
}


test-1-argparse
