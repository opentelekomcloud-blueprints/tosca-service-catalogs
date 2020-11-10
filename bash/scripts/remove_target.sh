#!/usr/bin/env bash

if [[ -n $remove_target ]]; then
  echo "Execute remove_target operation on $SOURCE_NODE"
  source $remove_target
fi