# Changelog

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