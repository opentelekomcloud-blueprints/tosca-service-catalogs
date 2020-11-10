#!/usr/bin/env bash

if [[ -n $delete ]]; then
  echo "Execute delete operation of component $NODE on $HOST"
  source $delete
fi