#!/usr/bin/env bash

# Available environment variables
# NODE: the node name.
# HOST: the node that host this bash component.
# DEPLOYMENT_ID: the unique deployment identifier.
# INSTANCE: if this node is scalable, returns the unique instance ID.
# INSTANCES: if this node is scalable, returns a comma separated list of all available instance IDs.

echo "Creating $NODE..."