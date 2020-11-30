#!/usr/bin/env bash

if [[ -n $add_source ]]; then
  echo "Execute add_source operation of $SOURCE_NODE on $TARGET_HOST"
  source $add_source
fi