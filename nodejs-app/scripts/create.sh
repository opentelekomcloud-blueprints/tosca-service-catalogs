#!/bin/bash

if [[ -n $GITHUB_URL ]]; then
  echo "Fetch $GITHUB_URL..."
  mkdir -p $DEPLOY_PATH
  cd $DEPLOY_PATH
  git clone $GITHUB_URL .
  npm install
else
  if [[ -n $js_script ]]; then
    mkdir -p ${DEPLOY_PATH}
    echo "Copy $js_script to $DEPLOY_PATH"
    cp $js_script ${DEPLOY_PATH}/js_script.js
  else
    echo "github_url or js_script not specified"
    exit 1
  fi
fi
