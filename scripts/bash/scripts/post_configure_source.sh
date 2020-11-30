#!/usr/bin/env bash

if [[ -n $post_configure_source ]]; then
  echo "Execute post_configure_source operation of $SOURCE_NODE on $SOURCE_HOST"
  source $post_configure_source
fi