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

Example status.detail

```
  $ cat status.detail
  status: COMPLETED
  time: 2026-09-15 09:37:43 UTC
  bootstrap-complete exit code: 0
  --- last 20 lines of .openshift_install.log ---
  time="2026-09-15T09:05:05Z" level=debug msg="  Loading Base Domain..."
  time="2026-09-15T09:05:05Z" level=debug msg="  Loading Platform..."
  time="2026-09-15T09:05:05Z" level=debug msg="  Loading Pull Secret..."
  time="2026-09-15T09:05:05Z" level=debug msg="  Loading Platform..."
  time="2026-09-15T09:05:05Z" level=debug msg="Using Install Config loaded from state file"
  time="2026-09-15T09:05:05Z" level=info msg="Waiting up to 45m0s (until 9:50AM UTC) for bootstrapping to complete..."
  time="2026-09-15T09:16:30Z" level=debug msg="Bootstrap status: complete"
  time="2026-09-15T09:16:30Z" level=info msg="Waiting for the bootstrap etcd member to be removed..."
  time="2026-09-15T09:17:31Z" level=debug msg="Error getting etcd operator singleton, retrying: the server was unable to return a response in the time allotted, but may still be processing the request (get etcds.operator.openshift.io cluster)"
  time="2026-09-15T09:18:41Z" level=debug msg="Error getting etcd operator singleton, retrying: Get \"https://api.openshift.tri-test2.com:6443/apis/operator.openshift.io/v1/etcds/cluster\": dial tcp 10.0.0.5:6443: connect: connection refused"
  time="2026-09-15T09:18:45Z" level=info msg="Bootstrap etcd member has been removed"
  time="2026-09-15T09:18:45Z" level=info msg="It is now safe to remove the bootstrap resources"
  time="2026-09-15T09:18:45Z" level=debug msg="Time elapsed per stage:"
  time="2026-09-15T09:18:45Z" level=debug msg="Bootstrap Complete: 15m28s"
  time="2026-09-15T09:18:45Z" level=debug msg="               API: 1m49s"
  time="2026-09-15T09:18:45Z" level=info msg="Time elapsed: 15m28s"
  --- cluster operators not available ---
  --- nodes not ready ---
  --- pending CSRs --
```

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