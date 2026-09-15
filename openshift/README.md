# otc.servicecatalogs.openshift

## About

* Installing OpenShift on OpenStack User-Provisioned Infrastructure

https://github.com/openshift/installer/blob/release-4.12/docs/user/openstack/install_upi.md

## Change logs

### 1.0.9

Make `openshift_checks.sh` fail-closed and add bootstrap monitoring:

* New stages `BOOTSTRAP_IN_PROGRESS`, `BOOTSTRAP_COMPLETE`, `BOOTSTRAP_FAILED`: the script runs
  `openshift-install wait-for bootstrap-complete` in the background on the Bastionhost and derives the
  stage from its exit code (`bootstrap.rc`). A bootstrap node that cannot pull images or start the
  temporary API is now reported as `BOOTSTRAP_FAILED` instead of silently blocking the install.
* The API availability is re-checked on every run. If the API answered before and stops responding,
  the status regresses to `API_UNREACHABLE`. Failed or empty `oc` output is never treated as success
  (previously an unreachable API produced `MASTER_NODES_READY`/`APPROVING_WORKER_NODES`).
* New file `/home/ubuntu/openshift/status.detail` with the last 20 lines of `.openshift_install.log`,
  cluster operators not `Available`, nodes not `Ready` and pending CSRs. `CheckOpenShiftStatus`
  prints it in its failure message.
* Fix the worker-ready count to use the worker node label instead of a column position.

### 1.0.8

Fix OpenShift pullSecret rendering for ansible-core >= 2.19

### 1.0.7

Update `openshift_checks.sh` to delete `bootstrap.ign` file on Bastionhost when status is COMPLETED.

### 1.0.6

Fix "no package nginx" found error by running apt-get update before install nginx.

### 1.0.5

Update for intalling OpenShift v4.16

### 1.0.4

Add configs to Support Swiss OTC auth_url endpoint.