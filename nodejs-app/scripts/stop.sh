#!/bin/bash


echo "BEGIN app stop"

if [[ -n $GITHUB_URL ]]; then
  cd $DEPLOY_PATH
  sudo npm stop
else
  sudo forever stop ${DEPLOY_PATH}/js_script.sh
fi

echo "END app stop"
