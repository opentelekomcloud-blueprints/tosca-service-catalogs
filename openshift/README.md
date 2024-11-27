# otc.servicecatalogs.openshift

## About

* Installing OpenShift on OpenStack User-Provisioned Infrastructure

https://github.com/openshift/installer/blob/release-4.12/docs/user/openstack/install_upi.md

## Change logs

### 1.0.7

Update `openshift_checks.sh` to delete `bootstrap.ign` file on Bastionhost when status is COMPLETED.

### 1.0.6

Fix "no package nginx" found error by running apt-get update before install nginx.

### 1.0.5

Update for intalling OpenShift v4.16

### 1.0.4

Add configs to Support Swiss OTC auth_url endpoint.