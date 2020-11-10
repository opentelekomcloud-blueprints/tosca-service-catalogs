#!/usr/bin/env bash

# Available environment variables in a relationship with a target node
# TARGET_NODE: The node name that is targeted by the relationship.
# TARGET_INSTANCE: if the target node is scalable, returns the instance ID that is targeted by the relatonship.
# TARGET_INSTANCES: if the target node is scalable, returns comma separated list of all available instance IDs for the target node.
# TARGET_HOST: The node that host the target node.
# SOURCE_NODE: The node name that is the source of the relationship.
# SOURCE_INSTANCE: if the source node is scalable, returns the instance ID of the source of the relationship.
# SOURCE_INSTANCES: if the source node is scalable, returns comma separated list of all available source instance IDs.
# SOURCE_HOST: The node that host the source node.
# DEPLOYMENT_ID: the unique deployment identifier.

echo "Configuring node $SOURCE_NODE in a relationship with node $TARGET_NODE..."

echo "The source node $SOURCE_NODE has an ip address: $SOURCE_IP"
echo "The target node $TARGET_NODE has an ip address: $TARGET_IP"

echo "The source node $SOURCE_NODE has the input env variable: ${SOURCE_ENV}"
echo "The target node $TARGET_NODE has the input env variable: ${TARGET_ENV}"