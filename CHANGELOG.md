# Changelog

## 19.12.2025

* Add template OpenShift `4.18.27`.

## 03.09.2025

* Add templates CCE and ArgoCD.

## 11.06.2025

* Fixed deployment of Nextcloud template failed because Ubuntu 20.04 is end of life:

1. Update the compute OS to use Ubuntu 22.04 instead of 20.04.
2. Update `otc.servicecatalogs.php:1.1.1` to use the ansible role [geerlingguy.php](https://github.com/geerlingguy/ansible-role-php) with tag `6.0.0` and installs PHP version `8.2` by default.
3. Improve `otc.servicecatalogs.nextcloud:1.2.1` to ensure bzip2 is installed. This is required to unpack the nextcloud archive.

* Removed the `stop` interface from the Bash script component in `otc.paas.scripts:1.1.2`. From now on, the undeployment process will not call the `stop` interface of the Bash script anymore.

## 01.04.2025

* Update `Bash` component with version `1.1.1` to have the environment variable `ÌP_ADDRESS`, which is the private IP address of the host compute.

## 03.01.2025

* Update `Prometheus` template to also use a `NATGateway` because [VPC Shared SNAT End of Life 01.01.2025](https://www.open-telekom-cloud.com/en/support/release-notes/vpc-shared-snat-end-of-life-01-01-2025).

## 27.11.2024

* Update `otc.servicecatalogs.openshift:1.0.7` to delete `bootstrap.ign` file after the deployment of OpenShift completes.
* Update all OpenShift templates 4.12, 4.13, 4.16 to use the image `Standard_Ubuntu_24.04_amd64_uefi_latest` for the bastion host.

## 26.11.2024

* Add template OpenShift `4.16.19` (latest stable version).
* Update `otc.servicecatalogs.openshift:1.0.6` to deploy on Swiss OTC and fix "no package nginx" found error.

## 17.10.2024

* Update template `Prometheus` with version `2.54.1`. This version uses Prometheus `2.54.1`, Grafana `11.2.2`, Node exporter `1.8.2`, Alert Manager `0.27.0`.
* Update the prometheus roles to the release `0.19.0` of the [Ansible Collection for Prometheus](https://github.com/prometheus-community/ansible).
* The prometheus roles requires ansible >= `2.16` because the use of `ansible.builtin.include` in the previous ansible versions is deprecated.

## 18.09.2024

* Update template `NextCloud` to use RDS with new volume_type `CLOUDSSD`. The old volume type `COMMON` is not available on OTC anymore.

## 22.04.2024

* Add service catalog `ÒpenShift`.
* Move all app templates in the folder `templates`.

## 31.08.2022

### Upgrade Nextcloud app v1.2.0

* Nextcloud app can now connect to the Object Storage of Open Telekom Cloud.
* It uses the runtime attributes of Object Storage (i.e., `bucket_id`, `bucket_domain_name`) for configuring the `config.php` file.

## 20.07.2022

### Upgrade PHP v1.1.0

* Change relationship of PHP from `dependsOn` to `hostedOn` Apache server.
* Fix ansible package_facts take long time to complete (use `service_facts` instead).

## 09.06.2022

### Nextcloud app

* Add `Nextcloud` app.
* Add `Apache` server.
* Add `PHP`.

### Update MySQLServer v1.1.0

* Support moving the default datadir of MySQL server (`/var/lib/mysql`) to a new location on the BlockStorage (e.g., `/mnt/mysql`) using the link `config_filesystem_as_datadir`.
* Auto config Apparmor for Debian and SELinux for RedHat family for the new location.
* Update the wordpress topology template `v1.2.0` to mount a BlockStorage on `/mnt`.

## 10.05.2022

* Add `MySQL` server and database.

## 03.05.2022

* Add `Wordpress`.

## 28.02.2022

* Add `Prometheus` monitoring.

## 14.09.2021

* Add MongoDB primary and secondary components for replication set config and user authentication.

## 25.08.2021

* Add hardening components `SshHardening` and `OsHardening` on a compute node.
