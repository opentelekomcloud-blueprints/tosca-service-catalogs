#!/bin/bash

# This script checks the status of the OpenShift installation and writes the status to /home/ubuntu/openshift/status.
# It is executed every minute by cron. Diagnostic context for the current status is written to
# /home/ubuntu/openshift/status.detail (installer log tail, non-available operators, not-ready nodes, pending CSRs).
#
# Stages (in order):
#  BOOTSTRAP_IN_PROGRESS: 'openshift-install wait-for bootstrap-complete' is running in background.
#  BOOTSTRAP_FAILED:      the installer gave up waiting for the bootstrap (exit code != 0). Terminal.
#  BOOTSTRAP_COMPLETE:    bootstrap finished, control plane handed over to the master nodes.
#  API_NOT_AVAILABLE:     bootstrap complete but the API has not answered yet.
#  API_AVAILABLE:         API is available.
#  API_UNREACHABLE:       API answered before but is not reachable any more (regression).
#  MASTER_NODES_NOT_READY / MASTER_NODES_READY
#  APPROVING_WORKER_NODES: masters ready, some operators are not up. Approving CSRs of worker nodes.
#  COMPLETED:             all operators available and more than one worker node ready. Sticky.
#
# Design rules:
#  - The API availability is re-evaluated on every run (except once COMPLETED), so the status can regress.
#  - Any failed/empty 'oc' output is treated as "unknown" and never as success.
#  - Bootstrap completion is derived from the installer exit code, never from log text.

OPENSHIFT_DIR="/home/ubuntu/openshift"
OPENSHIFT_API_URL="https://10.0.0.5:6443/version"
BOOTSTRAP_IGN_FILE="/var/www/html/bootstrap.ign"
STATUS_FILE="$OPENSHIFT_DIR/status"
DETAIL_FILE="$OPENSHIFT_DIR/status.detail"
INSTALL_LOG="$OPENSHIFT_DIR/.openshift_install.log"
BOOTSTRAP_RC="$OPENSHIFT_DIR/bootstrap.rc"
BOOTSTRAP_PID="$OPENSHIFT_DIR/bootstrap.pid"
# Set the path to the kubeconfig file
export KUBECONFIG="$OPENSHIFT_DIR/auth/kubeconfig"

set_status() {
  echo "$1" > "$STATUS_FILE"
}

current_status() {
  [[ -f "$STATUS_FILE" ]] && cat "$STATUS_FILE"
}

# Write diagnostic context for the current status. Informational only: no decision depends on it.
write_detail() {
  local api_ok="$1"
  {
    echo "status: $(current_status)"
    echo "time: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
    if [[ -f "$BOOTSTRAP_RC" ]]; then
      echo "bootstrap-complete exit code: $(cat "$BOOTSTRAP_RC")"
    fi
    if [[ -f "$INSTALL_LOG" ]]; then
      echo "--- last 20 lines of .openshift_install.log ---"
      tail -n 20 "$INSTALL_LOG"
    fi
    if [[ "$api_ok" == "true" ]]; then
      echo "--- cluster operators not available ---"
      oc get co -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{range .status.conditions[?(@.type=="Available")]}{.status}{end}{"\n"}{end}' 2>/dev/null \
        | awk -F'\t' '$2 != "True" {print}'
      echo "--- nodes not ready ---"
      oc get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{range .status.conditions[?(@.type=="Ready")]}{.status}{end}{"\n"}{end}' 2>/dev/null \
        | awk -F'\t' '$2 != "True" {print}'
      echo "--- pending CSRs ---"
      oc get csr -o jsonpath='{range .items[?(@.status.conditions==null)]}{.metadata.name}{"\t"}{.spec.username}{"\n"}{end}' 2>/dev/null
    fi
  } > "$DETAIL_FILE" 2>/dev/null
}

# Stage 1: bootstrap. Runs 'openshift-install wait-for bootstrap-complete' detached from cron and
# derives the stage from its exit code. Returns 0 when bootstrap is complete, exits otherwise.
check_bootstrap() {
  if [[ -f "$BOOTSTRAP_RC" ]]; then
    if [[ "$(cat "$BOOTSTRAP_RC")" == "0" ]]; then
      return 0
    fi
    set_status "BOOTSTRAP_FAILED"
    write_detail false
    exit 0
  fi
  # Fallback signal set by OpenShift itself, in case the watcher result is missing
  if [[ "$(oc get cm bootstrap -n kube-system -o jsonpath='{.data.status}' 2>/dev/null)" == "complete" ]]; then
    echo 0 > "$BOOTSTRAP_RC"
    return 0
  fi
  if [[ -f "$BOOTSTRAP_PID" ]] && kill -0 "$(cat "$BOOTSTRAP_PID")" 2>/dev/null; then
    set_status "BOOTSTRAP_IN_PROGRESS"
    write_detail false
    exit 0
  fi
  # Watcher not running and no result yet: (re)start it
  nohup sh -c "cd '$OPENSHIFT_DIR' && ./openshift-install wait-for bootstrap-complete --dir '$OPENSHIFT_DIR' --log-level=debug; echo \$? > '$BOOTSTRAP_RC'" >/dev/null 2>&1 &
  echo $! > "$BOOTSTRAP_PID"
  set_status "BOOTSTRAP_IN_PROGRESS"
  write_detail false
  exit 0
}

# Stage 2: API availability. Evaluated on every run so the status can regress.
check_api_availability() {
  local response
  response=$(curl -k -s -m 10 -o /dev/null -w "%{http_code}" "$OPENSHIFT_API_URL")
  if [[ "$response" == "200" ]]; then
    echo "OpenShift API is available."
    return 0
  fi
  echo "OpenShift API is not available. HTTP response code: $response"
  case "$(current_status)" in
    ""|BOOTSTRAP_*|API_NOT_AVAILABLE) set_status "API_NOT_AVAILABLE" ;;
    *) set_status "API_UNREACHABLE" ;;
  esac
  write_detail false
  exit 0
}

# Run an oc command into the variable OC_OUT. On failure or empty output mark the API unreachable
# and return 1 so the caller can stop without trusting empty data.
oc_or_unreachable() {
  if ! OC_OUT=$(oc "$@" 2>/dev/null) || [[ -z "$OC_OUT" ]]; then
    echo "oc $* failed or returned nothing"
    set_status "API_UNREACHABLE"
    return 1
  fi
  return 0
}

# Stage 3: all master nodes Ready
check_master_nodes_ready() {
  local nodes total ready
  oc_or_unreachable get nodes --selector=node-role.kubernetes.io/master --no-headers || return 1
  nodes="$OC_OUT"
  total=$(echo "$nodes" | wc -l)
  ready=$(echo "$nodes" | awk '$2 == "Ready"' | wc -l)
  if [[ "$ready" -gt 0 && "$ready" -eq "$total" ]]; then
    echo "OpenShift master nodes are ready."
    set_status "MASTER_NODES_READY"
  else
    echo "OpenShift master nodes are not all in the 'Ready' state ($ready/$total)."
    set_status "MASTER_NODES_NOT_READY"
  fi
}

# Stage 4: installation complete = all operators Available and more than one worker node Ready
check_complete() {
  local operators total available workers_ready
  oc_or_unreachable get co --no-headers || return 1
  operators="$OC_OUT"
  total=$(echo "$operators" | wc -l)
  available=$(echo "$operators" | awk '$3 == "True"' | wc -l)
  if [[ "$available" -gt 0 && "$available" -eq "$total" ]]; then
    workers_ready=$(oc get nodes -l node-role.kubernetes.io/worker --no-headers 2>/dev/null | awk '$2 == "Ready"' | wc -l)
    if [[ "$workers_ready" -gt 1 ]]; then
      echo "OpenShift installation is complete with more than one ready worker nodes"
      set_status "COMPLETED"
    else
      echo "All operators available but only $workers_ready worker node(s) ready."
      set_status "APPROVING_WORKER_NODES"
    fi
  else
    echo "OpenShift installation is still in progress ($available/$total operators available)."
    set_status "APPROVING_WORKER_NODES"
  fi
}

# Approve pending CSRs of worker nodes having a prefix of the INFRA_ID
approve_worker_nodes() {
  local infra_id pending_csrs csr
  infra_id="$(jq -r '.infraID' "$OPENSHIFT_DIR/metadata.json")"
  pending_csrs=$(oc get csr 2>/dev/null | grep -i Pending | awk '{print $1}')
  if [[ -z "$pending_csrs" ]]; then
    echo "Found no CSRs to approve"
    return
  fi
  for csr in $pending_csrs; do
    echo "Approving CSR: $csr"
    if oc describe csr "$csr" | grep 'Common Name' | awk '{print $3}' | grep -q "system:node:$infra_id-worker"; then
      oc adm certificate approve "$csr"
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

# Required oc and installer artifacts to run
if [[ ! -f "/usr/bin/oc" || ! -x "$OPENSHIFT_DIR/openshift-install" || ! -f "$KUBECONFIG" ]]; then
  exit 0
fi

# Installation completed: only keep approving new worker nodes
if [[ "$(current_status)" == "COMPLETED" ]]; then
  clean_up
  approve_worker_nodes
  exit 0
fi

for i in {1..2}
do
  check_bootstrap
  check_api_availability

  STATUS=$(current_status)
  case "$STATUS" in
    ""|BOOTSTRAP_*|API_NOT_AVAILABLE|API_UNREACHABLE)
      set_status "API_AVAILABLE"
      ;;
    API_AVAILABLE|MASTER_NODES_NOT_READY)
      check_master_nodes_ready || { write_detail false; exit 0; }
      ;;
    MASTER_NODES_READY|APPROVING_WORKER_NODES)
      approve_worker_nodes
      sleep 5
      approve_worker_nodes
      check_complete || { write_detail false; exit 0; }
      ;;
  esac
  write_detail true

  if [[ "$(current_status)" == "COMPLETED" ]]; then
    clean_up
    break
  fi
  if [[ "$i" == "1" ]]; then
    sleep 30
  fi
done
