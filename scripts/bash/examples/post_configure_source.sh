#!/usr/bin/env bash

# Available environment variables in a relationship with a target node
# https://docs.designer.otc-service.com/examples/script_components/env_vars_config

echo "Hello I am a default script $SOURCE_NODE executing on $SOURCE_HOST to connect with $TARGET_NODE at $TARGET_IP."
echo "You can upload a .sh file in the post_configure_source artifact of $SOURCE_NODE to replace me."