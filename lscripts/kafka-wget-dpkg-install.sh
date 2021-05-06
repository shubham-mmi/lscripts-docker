#!/bin/bash

## Copyright (c) 2021 mangalbhaskar. All Rights Reserved.
##__author__ = 'mangalbhaskar'
##__doc__='kafka.md'
###----------------------------------------------------------
## kafka
###----------------------------------------------------------
#
## References:
## * https://www.digitalocean.com/community/tutorials/how-to-install-apache-kafka-on-ubuntu-18-04
#
## `wget -c https://www.apache.org/dist/kafka/2.5.0/kafka_2.13-2.50.tgz`
##----------------------------------------------------------


trap ctrlc_handler INT

## trap 'exit 0' INT or simply trap INT 
function ctrlc_handler {
  (>&2 echo -e "\e[0;101m CTRL-C pressed; Terminating..!\e[0m\n")
  exit
}


function kafka-uninstall() {
  _log_.info "_prog: ${_prog}-uninstall"
}


function kafka-config() {
  _log_.info "_prog: ${_prog}-config"

  [[ ! -L ${BASEPATH}/${PROG} ]] && ln -s ${PROG_DIR} ${BASEPATH}/${PROG}

  ls -l ${BASEPATH}/${PROG} || _log_.fail "Installation does not exists: ${BASEPATH}/${PROG}"

  _log_.info " username=${KAFKA_USERNAME} groupname=${KAFKA_GROUPNAME}"
  _system_.create_nologin_user --username=${KAFKA_USERNAME} --groupname=${KAFKA_GROUPNAME}
  # su -l ${KAFKA_USERNAME}

  sudo chown -R ${KAFKA_USERNAME}:${KAFKA_GROUPNAME} ${PROG_DIR}
  ## -h flag to change the ownership of the link itself. Not specifying -h changes the ownership of the target of the link, which you explicitly did in the previous step.
  sudo chown -h ${KAFKA_USERNAME}:${KAFKA_GROUPNAME} ${BASEPATH}/${PROG}
}


function __kafka-install() {
  _log_.info "_prog: ${_prog}-install"
  echo "Number of threads will be used: ${NUMTHREADS}"
  echo "BASEPATH: ${BASEPATH}"
  echo "URL: ${URL}"
  echo "PROG_DIR: ${PROG_DIR}"

  source ${LSCRIPTS}/partials/wget.sh
  source ${LSCRIPTS}/partials/untargz.sh
}


function kafka-wget-install() {
  local LSCRIPTS=$( cd "$( dirname "${BASH_SOURCE[0]}")" && pwd )
  source ${LSCRIPTS}/lscripts.config.sh
  
  local scriptname=$(basename ${BASH_SOURCE[0]})
  _log_.debug "executing script...: ${scriptname}"

  source ${LSCRIPTS}/partials/basepath.sh

  local _prog="kafka"

  _log_.info "Install ${_prog}..."
  _log_.warn "sudo access is required!"

  local _default=no
  local _que
  local _msg

  ## program specific variables
  if [ -z "${KAFKA_VER}" ]; then
    local KAFKA_REL="2.5.0"
    local KAFKA_VER="2.13"
    echo "Unable to get KAFKA_VER version, falling back to default version#: ${KAFKA_VER}"
  fi

  # local PROG='kafka'
  local PROG=${_prog}
  local DIR="${PROG}-${KAFKA_VER}"
  local PROG_DIR="${BASEPATH}/${PROG}_${KAFKA_VER}-${KAFKA_REL}"
  local FILE="${PROG}_${KAFKA_VER}-${KAFKA_REL}.tgz"

  local URL="https://www.apache.org/dist/kafka/${KAFKA_REL}/${FILE}"

  local KAFKA_HOME=${BASEPATH}/${_prog}
  local KAFKA_USERNAME=kafka
  local KAFKA_GROUPNAME=kafka

  declare -gA __ENVVARS=()
  __ENVVARS['KAFKA_HOME']=${KAFKA_HOME}
  __ENVVARS['KAFKA_USERNAME']=${KAFKA_USERNAME}
  __ENVVARS['KAFKA_GROUPNAME']=${KAFKA_GROUPNAME}
  __ENVVARS['CFGFILE']=${KAFKA_GROUPNAME}

  function create_env_file() {
    _log_.info "create env"
    local env_file=${__ENVVARS['CFGFILE']}
    local env
    local _line
    
    _log_.info "env_file: ${env_file}"
    for env in "${!__ENVVARS[@]}"; do
      _line="${env}"=${__ENVVARS[${env}]}
      _log_.info ${_line}
      echo "${_line}" >> ${env_file}
    done
  }

  _que="Install ${_prog} now"
  _msg="Skipping ${_prog} installation!"
  _fio_.yesno_${_default} "${_que}" && \
      _log_.echo "Installing..." && \
      __${_prog}-install \
    || _log_.echo "${_msg}"


  _que="Configure ${_prog} now (recommended)"
  _msg="Skipping ${_prog} configuration. This is critical for proper python environment working!"
  _fio_.yesno_no "${_que}" && \
      _log_.echo "Configuring..." && \
      ${_prog}-config \
    || _log_.echo "${_msg}"


  _que="Verify ${_prog} now"
  _msg="Skipping ${_prog} verification!"
  _fio_.yesno_${_default} "${_que}" && {
      _log_.echo "Verifying..."
      source "${LSCRIPTS}/${_prog}-verify.sh" --home=${KAFKA_HOME} --username=${KAFKA_USERNAME}
    } || _log_.echo "${_msg}"
}

kafka-wget-install
