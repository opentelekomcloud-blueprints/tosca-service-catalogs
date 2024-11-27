#!/bin/bash

# This script checks the status of the Openshift installation and output the status in the file /home/ubuntu/openshift/status
# First it checks if Openshift API is available, then all master nodes are READY, then auto-approve CSR of worker nodes.
# We only approve CSRs with the prefix of the INFRA_ID
# Status:
#  API_AVAILABLE: API is available.
#  MASTER_NODES_READY: All master nodes are ready.
#  APPROVING_WORKER_NODES: Some operators are not up. Waiting for CSR requests from worker nodes and approve any.
#  COMPLETED: all operators are up and have more than one ready worker nodes. Console is now avaialble.

OPENSHIFT_DIR="/home/ubuntu/openshift"
OPENSHIFT_API_URL="https://10.0.0.5:6443/version"
BOOTSTRAP_IGN_FILE="/var/www/html/bootstrap.ign"
# Set the path to the kubeconfig file
export KUBECONFIG="$OPENSHIFT_DIR/auth/kubeconfig"

# Function to check if OpenShift API is available
check_api_availability() {
  response=$(curl -k -s -o /dev/null -w "%{http_code}" $OPENSHIFT_API_URL)
  if [[ $response -eq 200 ]]; then
    echo "OpenShift API is available."
    echo "API_AVAILABLE" > "$OPENSHIFT_DIR/status"
  else
    echo "OpenShift API is not available. HTTP response code: $response"
    echo "API_NOT_AVAILABLE" > "$OPENSHIFT_DIR/status"
    exit 0
  fi
}

# Function to check if OpenShift master nodes are ready
check_master_nodes_ready() {
  # Get the status of master nodes
  master_nodes_status=$(oc get nodes --selector=node-role.kubernetes.io/master --no-headers)

  # Check if all master nodes are in the "Ready" state
  if [[ $(echo "$master_nodes_status" | awk '{print $2}' | grep -c "Ready") -eq $(oc get nodes --selector=node-role.kubernetes.io/master --no-headers | wc -l) ]]; then
    echo "OpenShift master nodes are ready."
    echo "MASTER_NODES_READY" > "$OPENSHIFT_DIR/status"
  else
    echo "OpenShift master nodes are not all in the 'Ready' state."
    echo "MASTER_NODES_NOT_READY" > "$OPENSHIFT_DIR/status"
    exit 0  # Master nodes not ready
  fi
}

# Check if OpenShift installation is complete
# All operators available and have more than one ready worker node
check_complete() {
  # Check the status of OpenShift operators
  operators_status=$(oc get co --no-headers)
  if [[ $(echo "$operators_status" | awk '{print $3}' | grep -c "True") -eq $(oc get co --no-headers | wc -l) ]]; then
    WOKRERS_READY=$(oc get nodes | grep "Ready" | awk '{print $3}' | grep "worker" | wc -l)
    if [[ "$WOKRERS_READY" -gt "1" ]]; then
      echo "OpenShift installation is complete with more than one ready worker nodes"
      echo "COMPLETED" > "$OPENSHIFT_DIR/status"
    fi
  else
    echo "OpenShift installation is still in progress."
    echo "APPROVING_WORKER_NODES" > "$OPENSHIFT_DIR/status"
  fi
}

# Approve worker nodes having a prefix of the INFRA_ID
approve_worker_nodes() {
  # Get INFRA_ID
  INFRA_ID="$(jq -r '.infraID' "$OPENSHIFT_DIR/metadata.json")"
  # Get the list of pending CSRs of worker nodes having a prefix of the INFRA_ID
  PENDING_CSRS=$(oc get csr | grep -i Pending | awk '{print $1}')
  if [[ "$PENDING_CSRS" == "" ]]; then
    echo "Found no CRSs to approve"
  fi
  # Loop through pending CSRs and approve them
  for CSR in $PENDING_CSRS; do
    echo "Approving CSR: $CSR"
    oc describe csr $CSR | grep 'Common Name' | awk '{print $3}' | grep "system:node:$INFRA_ID-worker" > /dev/null
    if [ $? -eq 0 ]; then
      oc adm certificate approve $CSR
    fi
  done
}

clean_up() {
  if [[ -f "$BOOTSTRAP_IGN_FILE" ]]; then
    echo "Deleting bootstrap.ign..."
    sudo rm "$BOOTSTRAP_IGN_FILE"
    echo "bootstrap.ign deleted"
  fi
}

# Required oc to run
if [[ ! -f "/usr/bin/oc" ]]; then
  exit 0
fi

for i in {1..2}
do
  # Checks
  if [[ ! -f "$OPENSHIFT_DIR/status" ]]; then
    # First run
    check_api_availability
  else
    STATUS=$(cat "$OPENSHIFT_DIR/status")
    # Check until API is available
    if [[ "$STATUS" == "API_NOT_AVAILABLE" ]]; then
      check_api_availability
    # Check until all mastser nodes are ready
    elif [[ "$STATUS" == "API_AVAILABLE" || "$STATUS" == "MASTER_NODES_NOT_READY" ]]; then
      check_master_nodes_ready
    elif [[ "$STATUS" == "MASTER_NODES_READY" || "$STATUS" == "APPROVING_WORKER_NODES" ]]; then
      # Master nodes are ready, we approve worker nodes
      approve_worker_nodes
      # Do it twice
      sleep 5
      approve_worker_nodes
      # Check for installation complete
      check_complete
    elif [[ "$STATUS" == "COMPLETED" ]]; then
      clean_up
      # approve new worker nodes
      approve_worker_nodes
    fi
  fi
  if [[ "$i" == "1" ]]; then
    sleep 30
  fi
done