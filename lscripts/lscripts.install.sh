#!/bin/bash

## Copyright (c) 2024 mangalbhaskar. All Rights Reserved.
##__author__ = 'mangalbhaskar'
###----------------------------------------------------------
## Create install scripts alias
#
## References
# * https://stackoverflow.com/questions/20164917/variable-substitution-to-get-the-file-name-and-extension-in-bash
#
# ${filename%.*}   
# # % Deletes shortest match of pattern ".*" from back of "filename".
#
# ${filename#*.}   
# # Deletes the pattern '*.' from front of filename i.e. removes the name
###----------------------------------------------------------


function lsd-lscripts.install.__itemwise() {
  local _item
  local _item_filepath
  # for _item in "${_stack_install_itemwise[@]}";do
    # _item_filepath="${LSCRIPTS}/${_item}-install.sh"

  ## dynamically gets the install script names
  declare -a fnames=($(ls -1 ${LSCRIPTS}/*-install.sh | sort))
  for _item_filepath in "${fnames[@]}";do
    # lsd-mod.log.echo ${_item_filepath}
    # _item_filepath="${LSCRIPTS}/${_item}"
    ls -1 "${_item_filepath}" &>/dev/null && {
      _item=$(basename ${_item_filepath})
      _item=${_item%-install.*}
      # lsd-mod.log.echo "_item:${_item}"
      ## create alias
      alias lsd-install.${_item}="source ${_item_filepath} $@"
    } || lsd-mod.log.error "Installer not found: ${_item}!"
  done

  ## For 'itemwise' stack:
  _item='itemwise'
  _item_filepath="${LSCRIPTS}/stack-setup-${_item}.sh"
  ls -1 "${_item_filepath}" &>/dev/null && {
    ## create alias
    alias lsd-stack.${_item}="source ${_item_filepath} $@"
  } || lsd-mod.log.error "Installer not found: ${_item}!"
}


function lsd-lscripts.install.__stacksetup() {
  local _item
  local _item_filepath
  for _item in "${_stack_install_items[@]}";do
    # lsd-mod.log.info ${_item}
    _item_filepath="${LSCRIPTS}/stack-setup-${_item}.sh"
    # lsd-mod.log.echo "Checking for installer..." && \
    ls -1 "${_item_filepath}" &>/dev/null && {
      ## create alias
      alias lsd-stack.${_item}="source ${_item_filepath} $@"
    } || lsd-mod.log.error "Installer not found: ${_item}!"
  done

  ## For 'all' stack:
  _item='all'
  _item_filepath="${LSCRIPTS}/stack-setup-${_item}.sh"
  ls -1 "${_item_filepath}" &>/dev/null && {
    ## create alias
    alias lsd-stack.${_item}="source ${_item_filepath} $@"
  } || lsd-mod.log.error "Installer not found: ${_item}!"
}


function lsd-lscripts.install.__menu() {
  local _item

  PS3="Choose (1-${_menu_items[@]}):"
  lsd-mod.log.echo "Lscripts command options."
  select _item in "${_menu_items[@]}"
  do
    break
  done
  lsd-mod.log.echo "_item: ${_item}"
  # [[ ${_item} -neq "" ]] & {
  #   lsd-mod.log.echo "_item: ${_item}"
  # } || lsd-mod.log.info "Select an option"


  # local _item_filepath
  # for _item in "${_menu_items[@]}";do
  #   # lsd-mod.log.info ${_item}
  #   _item_filepath="${LSCRIPTS}/stack-setup-${_item}.sh"
  #   # lsd-mod.log.echo "Checking for installer..." && \
  #   ls -1 "${_item_filepath}" &>/dev/null && {
  #     ## create alias
  #     alias lsd-stack.${_item}="source ${_item_filepath} $@"
  #   } || lsd-mod.log.error "Installer not found: ${_item}!"
  # done

  # ## For 'all' stack:
  # _item='all'
  # _item_filepath="${LSCRIPTS}/stack-setup-${_item}.sh"
  # ls -1 "${_item_filepath}" &>/dev/null && {
  #   ## create alias
  #   alias lsd-stack.${_item}="source ${_item_filepath} $@"
  # } || lsd-mod.log.error "Installer not found: ${_item}!"
}


function lsd-lscripts.install.main() {
  local LSCRIPTS="$( cd "$( dirname "${BASH_SOURCE[0]}")" && pwd )"
  source "${LSCRIPTS}/core/_log_.sh"
  source "${LSCRIPTS}/core/config/stack-cfg.sh"

  # source "${LSCRIPTS}/_common_.sh"
  # lsd-mod.log.warn "Create installer alias ${FUNCNAME[0]}!"

  ## source ${LSCRIPTS}/lscripts.config.sh
  ## local scriptname=$(basename ${BASH_SOURCE[0]})
  ## lsd-mod.log.debug "executing script...: ${scriptname} with total params: $#"

  lsd-lscripts.install.__stacksetup
  lsd-lscripts.install.__itemwise
  # lsd-lscripts.install.__menu
}
