#!/usr/bin/env bash

if [[ -n $create ]]; then
  echo "Execute create operation of component $NODE on $HOST"
  source $create
fi