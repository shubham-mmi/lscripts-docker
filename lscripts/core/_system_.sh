#!/bin/bash

## Copyright (c) 2024 mangalbhaskar. All Rights Reserved.
##__author__ = 'mangalbhaskar'
###----------------------------------------------------------
## system utility functions
###----------------------------------------------------------


function lsd-mod.system.get__vars() {
  # local nocolor='\e[0m';
  # local bgre='\e[1;32m';

  lsd-mod.log.echo "NUMTHREADS: ${bgre}${NUMTHREADS}${nocolor}"
  lsd-mod.log.echo "MACHINE_ARCH: ${bgre}${MACHINE_ARCH}${nocolor}"
  lsd-mod.log.echo "USER_ID: ${bgre}${USER_ID}${nocolor}"
  lsd-mod.log.echo "GRP_ID: ${bgre}${GRP_ID}${nocolor}"
  lsd-mod.log.echo "USR: ${bgre}${USR}${nocolor}"
  lsd-mod.log.echo "GRP: ${bgre}${GRP}${nocolor}"
  lsd-mod.log.echo "LOCAL_HOST: ${bgre}${LOCAL_HOST}${nocolor}"
  lsd-mod.log.echo "OSTYPE: ${bgre}${OSTYPE}${nocolor}"
  lsd-mod.log.echo "OS_ARCH: ${bgre}${OS_ARCH}${nocolor}"
  lsd-mod.log.echo "OS_ARCH_BIT: ${bgre}${OS_ARCH_BIT}${nocolor}"
  lsd-mod.log.echo "LINUX_VERSION: ${bgre}${LINUX_VERSION}${nocolor}"
  lsd-mod.log.echo "LINUX_CODE_NAME: ${bgre}${LINUX_CODE_NAME}${nocolor}"
  lsd-mod.log.echo "LINUX_ID: ${bgre}${LINUX_ID}${nocolor}"
  lsd-mod.log.echo "LINUX_DISTRIBUTION: ${bgre}${LINUX_DISTRIBUTION}${nocolor}"
  lsd-mod.log.echo "LINUX_DISTRIBUTION_TR: ${bgre}${LINUX_DISTRIBUTION_TR}${nocolor}"
}


function lsd-mod.system.get__info() {
  type inxi &>/dev/null && inxi -Fxzd;
}


function lsd-mod.system.get__cpu_cores() {
  cat /proc/cpuinfo |grep -i 'core id'|wc -l
}


function lsd-mod.system.get__ip-public() {
  curl ifconfig.me
  echo -e ""
  curl icanhazip.com
  curl ipinfo.io/ip
  echo -e ""
  wget -qO- ifconfig.me
  echo -e ""
}


function lsd-mod.system.get__ip() {
  ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
}


function lsd-mod.system.get__numthreads() {
  ## Calculates 1.5 times physical threads
  local NUMTHREADS=1 ## disable MP
  if [[ -f /sys/devices/system/cpu/online ]]; then
    NUMTHREADS=$(( ( $(cut -f 2 -d '-' /sys/devices/system/cpu/online) + 1 ) * 15 / 10  ))
  fi
  echo "${NUMTHREADS}"
}


function lsd-mod.system.get__gpu_info() {
  ###----------------------------------------------------------
  ## GPU / Graphics card
  ## How do I find out the model of my graphics card?
  ## check for Graphics Hardware and System Architecture Details
  ###----------------------------------------------------------

  lspci -nnk | grep -i "VGA\|3D" -A3
  lspci -v -s $(lspci | grep VGA | cut -d" " -f 1)
  lspci | grep VGA
  lspci | grep -i nvidia
  arch
  type glxinfo &>/dev/null && glxinfo | grep OpenGL

  ## sudo lshw | grep -A10 "VGA\|3D"
  ## sudo lshw -c video
}


function lsd-mod.system.admin.create-login-user() {
  lsd-mod.log.info "It will create normal user with home and login!"
  lsd-mod.log.warn "sudo access is required!"
  ## Caution
  lsd-mod.log.warn "It will add the user as the sudoer!"

  local __LSCRIPTS=$( cd "$( dirname "${BASH_SOURCE[0]}")" && pwd )
  source ${__LSCRIPTS}/argparse.sh "$@"

  lsd-mod.log.warn "Total: $# should be equal to ${#args[@]} and args: ${args[@]}"

  local key
  for key in "${!args[@]}"; do
    [[ -n "${args[${key}]+1}" ]] && lsd-mod.log.echo "${key}=${args[${key}]}" || lsd-mod.log.error "Key does not exists: ${key}"
  done

  local username
  local groupname
  # [[ -n "${args['user']+1}" ]] && username=${args['user']} ||  username=${args['user']} 
  # [[ -n "${args['group']+1}" ]] && groupname=${args['group']} ||  groupname=${args['group']} 

  [[ -n "${args['user']+1}" ]] && [[ -n "${args['group']+1}" ]] && {
    username="${args['user']}"
    groupname="${args['group']}"

    lsd-mod.log.info "New system user (${username}) and new group (${groupname})"

    ##   -U, --user-group              create a group with the same name as the user
    ##   -r, --system                  create a system account
    ##   -M, --no-create-home          do not create the user's home directory
    ##   -s, --shell SHELL             login shell of the new account
    ##   -c, --comment COMMENT         GECOS field of the new account

    ## "Add user if it does not exists."
    id -u ${username} &> /dev/null || sudo useradd -c "User account" ${username}
    sudo gpasswd -d $(id -un) ${groupname} &> /dev/null
    sudo gpasswd -d ${username} ${groupname} &> /dev/null

    ## "Add new application system user to the secondary group, if it is not already added."
    getent group | grep ${username}  | grep ${groupname} &> /dev/null || {
      sudo groupadd ${groupname}
      sudo usermod -aG ${groupname} ${username}
    }

    ## "Adding current user to the secondary group, if it is not already added."
    ## "Also, adding the user to the sudo group so it can run commands in a privileged mode!"
    getent group | grep $(id -un) | grep ${groupname} &> /dev/null || {
      sudo usermod -aG ${groupname} $(id -un) && \
        sudo usermod -aG sudo ${username} && lsd-mod.log.echo "Successfully created system user"
      cat /etc/passwd | grep ${username}
    }
  } || lsd-mod.log.error "Invalid paramerters!"
}


function lsd-mod.system.admin.create-nologin-user() {
  lsd-mod.log.info "It will create no-login system user without the home directory!"
  lsd-mod.log.warn "sudo access is required!"
  ## Caution
  lsd-mod.log.warn "It will delete and re-create if the user or group already exists!"

  local __LSCRIPTS=$( cd "$( dirname "${BASH_SOURCE[0]}")" && pwd )
  source ${__LSCRIPTS}/argparse.sh "$@"

  lsd-mod.log.warn "Total: $# should be equal to ${#args[@]} and args: ${args[@]}"

  local key
  for key in "${!args[@]}"; do
    [[ -n "${args[${key}]+1}" ]] && lsd-mod.log.echo "${key}=${args[${key}]}" || lsd-mod.log.error "Key does not exists: ${key}"
  done

  local username
  local groupname
  [[ -n "${args['user']+1}" ]] && username=${args['user']} ||  username=${args['user']} 
  [[ -n "${args['group']+1}" ]] && groupname=${args['group']} ||  groupname=${args['group']} 

  lsd-mod.log.info "New system user (${username}) and new group (${groupname})"

  ##   -U, --user-group              create a group with the same name as the user
  ##   -r, --system                  create a system account
  ##   -M, --no-create-home          do not create the user's home directory
  ##   -s, --shell SHELL             login shell of the new account
  ##   -c, --comment COMMENT         GECOS field of the new account

  ## Delete the system user from the secondary group
  sudo userdel ${username} -r &> /dev/null
  sudo groupdel ${username} &> /dev/null
  sudo groupdel ${groupname} &> /dev/null

  ## "Add user if it does not exists."
  id -u ${username} &> /dev/null || sudo useradd -rUMs /usr/sbin/nologin -c "User account" ${username}
  sudo gpasswd -d $(id -un) ${groupname} &> /dev/null
  sudo gpasswd -d ${username} ${groupname} &> /dev/null

  ## "Add new system user (${username}) to the secondary group (${groupname}), if it is not already added."
  getent group | grep ${username}  | grep ${groupname} &> /dev/null || {
    sudo groupadd ${groupname}
    sudo usermod -aG ${groupname} ${username}
  }

  ## "Adding current user ($(id -un)) to the secondary group: (${groupname}), if it is not already added."
  getent group | grep $(id -un) | grep ${groupname} &> /dev/null || {
    sudo usermod -aG ${groupname} $(id -un) && lsd-mod.log.echo "Successfully created system user"
    cat /etc/passwd | grep ${username}
  }
}


function lsd-mod.system.admin.restrict-cmds-for-sudo-user() {
  local __LSCRIPTS=$( cd "$( dirname "${BASH_SOURCE[0]}")" && pwd )
  source ${__LSCRIPTS}/argparse.sh "$@"

  lsd-mod.log.warn "Total: $# should be equal to ${#args[@]} and args: ${args[@]}"

  local key
  for key in "${!args[@]}"; do
    [[ -n "${args[${key}]+1}" ]] && lsd-mod.log.echo "${key}=${args[${key}]}" || lsd-mod.log.error "Key does not exists: ${key}"
  done

  local username
  local groupname
  local scripts_filepath
  local cservicename
  [[ -n "${args['user']+1}" ]] && username=${args['user']} || lsd-mod.log.fail "username does not exists"

  [[ -n "${args['group']+1}" ]] && groupname=${args['group']} || ( groupname=${args['group']} && lsd-mod.log.info "groupname will be same as username: ${args['user']}" )

  [[ -n "${args['scripts_filepath']+1}" ]] && scripts_filepath=${args['scripts_filepath']} \
    ||  ( scripts_filepath="${_BZO__SCRIPTS}/lscripts-docker/lscripts/tests/test.sh" && lsd-mod.log.info "scripts_filepath: ${scripts_filepath}" )

  [[ -n "${args['cservicename']+1}" ]] && cservicename=${args['cservicename']} \
    ||  ( cservicename="${username}.service" && lsd-mod.log.info "cservicename: ${cservicename}" )

  local _que
  local _msg
  _que="Do you want proceed with system user creation process"
  _msg="Skipping system user creation process."
  lsd-mod.fio.yesno_yes "${_que}" && \
      lsd-mod.log.echo "Executing system user creation process..." && \
      lsd-mod.system.admin.create-nologin-user --user=${username} --group=${groupname} \
    || lsd-mod.log.echo "${_msg}"


  _que="Do you want proceed with configure restrictive sudo access"
  _msg="Skipping sudo configuration."
  lsd-mod.fio.yesno_no "${_que}" && {
      local L1
      local L2
      local FILE
      ## Allow only specific services and commands to be executed without sudo
      ## Inject in sudoer file using visudo and only when it does not exits
      FILE=/etc/sudoers
      L1="Cmnd_Alias AISERVICES = ${scripts_filepath}, /bin/systemctl status ${cservicename}, /bin/systemctl reload ${cservicename}, /bin/systemctl restart ${cservicename}"
      L2="$(id -un) ALL=(${username}:${groupname}) NOPASSWD: AISERVICES"
      sudo grep -qF "$L1" "$FILE" || echo -e "$L1" | sudo EDITOR='tee -a' visudo &> /dev/null 
      sudo grep -qF "$L2" "$FILE" || echo -e "$L2" | sudo EDITOR='tee -a' visudo

      ## list the group members along with their GIDs
      id ${username}

      ## permissions: r 4; w 2; x 1;  
      ## make ${username} as the owner of specific directory
      sudo chown -R ${username}:${groupname} ${scripts_filepath}

      ## only owner has the permission to read and execute
      sudo chmod -R 500 ${scripts_filepath}

      ## kill the sudo timeout and reset, so we know that the test really works
      sudo -k

      ## Test - this should print hello
      ## systen usercan execute without these scripts without sudo password
      sudo -u ${username} -s /bin/bash ${scripts_filepath} hello

      echo -e "\nUsage:
      sudo -u ${username} -s /bin/bash ${scripts_filepath} hello
      sudo -u ${username} systemctl [status|reload|restart] ${username}.service"
    } || lsd-mod.log.echo "${_msg}"
}


function lsd-mod.system.df_json {
  ## Referenecs:
  ## https://www.unix.com/unix-for-beginners-questions-and-answers/282491-how-convert-any-shell-command-output-json-format.html
  local keys
  local vals
  echo `df -h . | tr -s ' ' ',' | jq -nR '[ 
    ( input | split(",") ) as $keys | 
    ( inputs | split(",") ) as $vals | 
    [ [$keys, $vals] | 
    transpose[] | 
    {key:.[0],value:.[1]} ] | 
    from_entries ]'`
}


function lsd-mod.system.get__osinfo() {
  local id=$(. /etc/os-release;echo ${ID})
  local version_id=$(. /etc/os-release;echo ${VERSION_ID})
  local distribution=$(. /etc/os-release;echo ${ID}${VERSION_ID})
  local version_codename=$(. /etc/os-release;echo ${VERSION_CODENAME})

  echo "id: ${id}"
  echo "version_id: ${version_id}"
  echo "distribution: ${distribution}"
  echo "version_codename: ${version_codename}"
}


function lsd-mod.system.select__prog() {
  ## Todo
  local _prog=$1

  [[ ! -z ${_prog} ]] && {
    sudo update-alternatives --config ${_prog}
  } || lsd-mod.log.echo "Invalid update-alternatives"
}


function lsd-mod.system.select__cuda() {
  lsd-mod.system.select__prog cuda
}


function lsd-mod.system.select__bazel() {
  lsd-mod.system.select__prog bazel
}


function lsd-mod.system.select__gcc() {
  lsd-mod.system.select__prog gcc
}


# ## Todo: cleanup
# function lsd-mod.system.__create_appuser() {
#   source ${LSCRIPTS}/core/argparse.sh "$@"

#   lsd-mod.log.warn "Total: $# should be equal to ${#args[@]} and args: ${args[@]}"

#   local key
#   for key in "${!args[@]}"; do
#     [[ -n "${args[${key}]+1}" ]] && lsd-mod.log.echo "${key}=${args[${key}]}" || lsd-mod.log.error "Key does not exists: ${key}"
#   done

#   local L1
#   local L2
#   local FILE
#   # local username="boozo"
#   # local groupname="boozo"
#   # local scripts_path="/boozo-hub/boozo/scripts"

#   local username="${args['user']}"
#   local groupname="${args['group']}"
#   local scripts_path="${args['scripts_path']}"

#   [[ -z ${username} ]] || username="boozo"
#   [[ -z ${groupname} ]] || username="boozo"
#   [[ -d ${scripts_path} ]] || lsd-mod.log.fail "scripts_path does not exists: ${scripts_path}"

#   local cservicename="${username}.service"

#   ## delete the exisitng user; if needed, otherwise keep it commented
#   sudo userdel ${username} -r &> /dev/null
#   sudo groupdel ${groupname}

#   ##   -U, --user-group              create a group with the same name as the user
#   ##   -r, --system                  create a system account
#   ##   -M, --no-create-home          do not create the user's home directory
#   ##   -s, --shell SHELL             login shell of the new account
#   ##   -c, --comment COMMENT         GECOS field of the new account

#   ## add user if it does not exists
#   id -u ${username} &> /dev/null || sudo useradd -rUMs /usr/sbin/nologin -c "AI application user account" ${username}


#   ## add system user to the secondary group, if it is not already added
#   getent group | grep $(id -un) | grep ${groupname} &> /dev/null || sudo usermod -aG ${groupname} $(id -un)

#   ## delete the system user from the secondary group if needed, otherwise keep it commented
#   ## sudo gpasswd -d $(id -un) ${groupname}

#   ## allow only specific services and commands to be executed without sudo
#   ## Inject in sudoer file using visudo and only when it does not exits
#   FILE=/etc/sudoers
#   L1="Cmnd_Alias AISERVICES = ${scripts_path}/test.sh, ${scripts_path}/flip.sh, /bin/systemctl status ${cservicename}, /bin/systemctl reload ${cservicename}, /bin/systemctl restart ${cservicename}"
#   L2="$(id -un) ALL=(${username}:${groupname}) NOPASSWD: AISERVICES"
#   sudo grep -qF "$L1" "$FILE" || echo -e "$L1" | sudo EDITOR='tee -a' visudo &> /dev/null 
#   sudo grep -qF "$L2" "$FILE" || echo -e "$L2" | sudo EDITOR='tee -a' visudo

#   # echo -e "$L1" | sudo EDITOR='tee -a' visudo
#   # echo "$L2" | sudo EDITOR='tee -a' visudo

#   ## list the group members along with their GIDs
#   id ${username}

#   ## permissions: r 4; w 2; x 1;  

#   ## make ${username} as the owner of specific directory
#   sudo chown -R ${username}:${groupname} ${scripts_path}

#   ## only owner has the permission to read and execute
#   # sudo chmod 500 ${scripts_path}/*.sh
#   sudo chmod -R 500 ${scripts_path}

#   ## kill the sudo timeout and reset, so we know that the test really works
#   sudo -k

#   ## Test - this should print hello
#   ## systen usercan execute without these scripts without sudo password
#   sudo -u ${username} -s /bin/bash ${scripts_path}/test.sh hello

#   echo -e "\nUsage:
#   sudo -u ${username} -s /bin/bash ${scripts_path}/test.sh hello
#   sudo -u ${username} -s /bin/bash ${scripts_path}/flip.sh
#   sudo -u ${username} systemctl [status|reload|restart] aimlhub.service"
# }


# function lsd-mod.system.__add_userusername{
#   source ${LSCRIPTS}/core/argparse.sh "$@"

#   [[ "$#" -ne "2" ]] && lsd-mod.log.fail "Invalid number of paramerters: required 2 given $#"
#   [[ -n "${args['user']+1}" ]] && [[ -n "${args['group']+1}" ]] && {
#     # (>&2 echo -e "key: 'username' exists")
#     local username="${args['user']}"
#     local groupname="${args['group']}"

#     ## Create the user that will run the service
#     sudo useradd ${username}

#     ## Set bash as the default shell for the user
#     sudo usermod --shell /bin/bash ${username}

#     ## Set a password for this user
#     sudo passwd ${username}

#     ## add the user to the sudo group so it can run commands in a privileged mode
#     # sudo adduser ${username} sudo
#     sudo usermod -aG sudo ${username}

#     ## In terms of security, it is recommended that you allow SSH access to as few users as possible
#     ## Disable SSH access for both your newly created user and root user in this step.
#     ## Save and exit the file and then restart the SSH daemon to activate the changes.
#     # ```
#     # sudo vi /etc/ssh/sshd_config
#     # PermitRootLogin no
#     ## Under the PermitRootLogin value, add a DenyUsers line and set the value as any user who should have SSH access disabled:
#     # DenyUsers ${username}
#     # ```
#     # sudo systemctl restart sshd
#     # 
#   } || lsd-mod.log.error "Invalid paramerters!"
# }
