# otc.servicecatalogs.hardening

## About

Hardening is the process of securing a system by reducing vulnerability and available ways of attack. For example: If your server is not a desktop system, then Xorg, KDE/GNOME/Unity must be disabled.

If you on-boarding your applications on Open Telekom Cloud, you may know about the [Privacy Security Assessment (PSA) process](https://www.telekom.com/en/corporate-responsibility/data-protection-data-security/security/details/privacy-and-security-assessment-process-358312). These are hundreds of security guidelines from Deutsche Telekom that your applications should be fulfilled.

This service catalog (when putting on a compute node) automates the security requirements of Deutsche Telekom on the booted VM.

## How to use

* Put the component `SshHardening` (and/or `OsHardening`) on a compute node.
* Customize the property as needed (e.g., enable/disable SSH agent forwarding).

![Fig. SSH Hardening](https://docs.designer.otc-service.com/img/ctd-pics/service-catalogs-ssh-hardning.png 'SSH Hardening')

The default properties enforce hardening on the VM following the [SSH Baseline](https://dev-sec.io/baselines/ssh/) and the [Linux Security Baseline](https://dev-sec.io/baselines/linux/) from the DevSec project so you do not need to do anything further. For example, when putting the `SshHardening` on a compute node, SSH agent forwarding is disabled on the VM by default as it can be used in a limited way to enable attacks (See the requirement **ssh-11** from the [SSH Baseline](https://dev-sec.io/baselines/ssh/)).

## About the DevSec project

Deutsche Telekom, T-Labs, and Telekom Security funded the initial research of this project and open source the automation to help foster a more secure world. This service catalog uses the ansible implementation of this project.