#!/usr/bin/env bash

if [[ -n $stop ]]; then
  echo "Execute stop operation of $NODE on $HOST"
  source $stop
fi