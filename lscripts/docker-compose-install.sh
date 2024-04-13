#!/bin/bash

## Copyright (c) 2024 mangalbhaskar. All Rights Reserved.
##__author__ = 'mangalbhaskar'
###----------------------------------------------------------
## docker-compose
###----------------------------------------------------------
##
## References:
## * https://docs.docker.com/compose/install/
## * https://www.digitalocean.com/community/tutorials/how-to-install-docker-compose-on-ubuntu-16-04
## * https://linuxize.com/post/how-to-install-and-use-docker-compose-on-ubuntu-18-04/
## * https://github.com/docker/compose/releases
###----------------------------------------------------------


function docker-compose-uninstall() {
  ## Uninstallation
  sudo rm /usr/local/bin/docker-compose
}


function __docker-compose-install() {
  sudo curl -L "${DOCKER_COMPOSE_URL}" -o /usr/local/bin/docker-compose

  sudo chmod +x /usr/local/bin/docker-compose

  ## sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

}


function docker-compose-install.main() {
  local LSCRIPTS=$( cd "$( dirname "${BASH_SOURCE[0]}")" && pwd )
  source ${LSCRIPTS}/lscripts.config.sh

  local _prog="docker-compose"

  lsd-mod.log.info "Install ${_prog}..."
  lsd-mod.log.warn "sudo access is required!"

  local _default=yes
  local _que
  local _msg

  _que="Uninstall previous ${_prog} installation"
  _msg="Skipping ${_prog} uninstall!"
  lsd-mod.fio.yesno_${_default} "${_que}" && \
      lsd-mod.log.echo "Uninstalling..." && \
          ${_prog}-uninstall \
    || lsd-mod.log.echo "${_msg}"

  _que="Install ${_prog} now"
  _msg="Skipping ${_prog} installation!"
  lsd-mod.fio.yesno_${_default} "${_que}" && \
    lsd-mod.log.echo "Installing..." && \
    __${_prog}-install \
    || lsd-mod.log.echo "${_msg}"

  _que="Verify ${_prog} now"
  _msg="Skipping ${_prog} verification!"
  lsd-mod.fio.yesno_${_default} "${_que}" && \
      lsd-mod.log.echo "Verifying..." && \
      source "${LSCRIPTS}/${_prog}-verify.sh" \
    || lsd-mod.log.echo "${_msg}"

}

docker-compose-install.main "$@"
