#!/usr/bin/env bash

if [[ -n $configure ]]; then
  echo "Execute configure operation of component $NODE on $HOST"
  source $configure
fi