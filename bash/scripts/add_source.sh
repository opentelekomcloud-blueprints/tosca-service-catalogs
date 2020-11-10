#!/usr/bin/env bash

if [[ -n $add_source ]]; then
  echo "Execute add_source operation on $TARGET_NODE"
  source $add_source
fi