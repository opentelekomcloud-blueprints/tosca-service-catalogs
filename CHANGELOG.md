# Changelog

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
