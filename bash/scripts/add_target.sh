#!/usr/bin/env bash

if [[ -n $add_target ]]; then
  echo "Execute add_target operation on $SOURCE_NODE"
  source $add_target
fi