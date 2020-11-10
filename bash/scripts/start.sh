#!/usr/bin/env bash

if [[ -n $start ]]; then
  echo "Execute start operation of component $NODE on $HOST"
  source $start
fi