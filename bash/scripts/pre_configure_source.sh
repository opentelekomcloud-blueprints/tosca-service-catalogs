#!/usr/bin/env bash

if [[ -n $pre_configure_source ]]; then
  echo "Execute pre_configure_source operation on $SOURCE_NODE"
  source $pre_configure_source
fi