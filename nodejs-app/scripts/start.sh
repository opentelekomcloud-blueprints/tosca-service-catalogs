#!/bin/bash

is_port_open () {
    host=$1
    port=$2
    exec 6<>/dev/tcp/${host}/${port} || return 1
    exec 6>&- # close output connection
    exec 6<&- # close input connection
    return 0
}

wait_for_command_to_succeed () {
    cmd=$1
    timeout=60
    interval=5
    if [[ $# -ge 2 ]] ; then
        ((timeout = $2))
    fi
    if [[ $# -ge 3 ]] ; then
        ((interval = $3))
    fi
    while ((timeout > 0)) ; do
        if eval ${cmd}
        then
            return 0
        else
            echo "Waiting for cmd ${cmd} to success"
            sleep $interval
            (( timeout -= interval ))
        fi
    done
    return 1
}

wait_for_port_to_be_open () {
    host=$1
    shift
    port=$1
    shift
    cmd="is_port_open ${host} ${port}"
    if wait_for_command_to_succeed "${cmd}" $@
    then
        return 0
    else
        echo "Timeout occures while awaiting for port ${host}:${port} to be open."
        return 1
    fi
}

if [[ -n $GITHUB_URL ]]; then
  cd $DEPLOY_PATH
  # npm start not work with terraform
  # https://github.com/hashicorp/terraform/issues/6229
  START=$(cat package.json | awk -F 'node' '/"start"/{print $2}' | tr -d '[[:space:]|\|,"]')
  sudo forever start -o out.log -e err.log $START
else
  if [[ -n $js_script ]]; then
  	# nohup not work with node in terraform 
	  # https://github.com/hashicorp/terraform/issues/6229
    sudo forever start -o ${DEPLOY_PATH}/out.log -e ${DEPLOY_PATH}/err.log ${DEPLOY_PATH}/js_script.js
  fi
fi

wait_for_port_to_be_open "127.0.0.1" "${PORT}" || error_exit "Cannot open port ${PORT}"