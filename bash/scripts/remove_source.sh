#!/usr/bin/env bash

if [[ -n $remove_source ]]; then
  echo "Execute remove_source operation on $TARGET_NODE"
  source $remove_source
fi