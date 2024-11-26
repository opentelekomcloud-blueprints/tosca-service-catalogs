#!/usr/bin/env python
# Create manifests, ignition files
# see also https://github.com/openshift/installer/blob/release-4.12/docs/user/openstack/install_upi.md

import subprocess
import os
import yaml
import base64
import json
import sys

OPENSHIFT_DIR='/home/ubuntu/openshift/'
MANIFESTS_DIR=OPENSHIFT_DIR+'manifests'
AUTH_DIR=OPENSHIFT_DIR+'auth'
KUBEADMIN_PASSWORD_FILE=AUTH_DIR+'/kubeadmin-password'
INSTALL_CONFIG_FILE=OPENSHIFT_DIR+'install-config.yaml'
SCHEDULER_CONFIG_FILE=OPENSHIFT_DIR+'manifests/cluster-scheduler-02-config.yml'
BOOTSTRAP_IGN_FILE=OPENSHIFT_DIR+'bootstrap.ign'
MASTER_IGN_FILE=OPENSHIFT_DIR+'master.ign'

if os.path.exists(MANIFESTS_DIR):
  print('Found Openshift manifests. Skip generating manifests.')
elif os.path.exists(AUTH_DIR):
  print('Found Openshift auth directory. Skip generating manifests.')
else:
  if not os.path.exists(INSTALL_CONFIG_FILE):
    print('The file install-config.yaml does not exist. Failed to generate manifests files.')
    os._exit(1)
  else:
    print('Generate Openshift manifests...')
    process = subprocess.run(['./openshift-install', 'create', 'manifests'],
                             stdout=subprocess.PIPE,
                             universal_newlines=True,
                             cwd=OPENSHIFT_DIR)
    print(process.stdout)

if os.path.exists(OPENSHIFT_DIR+"/openshift"):
  print('Remove Machines and MachineSets')
  process2 = subprocess.run(['rm -f openshift/99_openshift-cluster-api_master-machines-*.yaml openshift/99_openshift-cluster-api_worker-machineset-*.yaml openshift/99_openshift-machine-api_master-control-plane-machine-set.yaml'],
                           shell=True,
                           stdout=subprocess.PIPE,
                           universal_newlines=True,
                           cwd=OPENSHIFT_DIR)

if os.path.exists(MANIFESTS_DIR):
  print('Make control-plane nodes unschedulable by setting mastersSchedulable to False:')
  data = yaml.safe_load(open(SCHEDULER_CONFIG_FILE))
  data['spec']['mastersSchedulable'] = False
  print(data)
  open(SCHEDULER_CONFIG_FILE, 'w').write(yaml.dump(data, default_flow_style=False))

if os.path.exists(AUTH_DIR):
  print('Found Openshift auth. Skip generating ignition configs.')
else:
  print('Generate ignition configs...')
  process3 = subprocess.run(['./openshift-install', 'create', 'ignition-configs'],
                           stdout=subprocess.PIPE,
                           universal_newlines=True,
                           cwd=OPENSHIFT_DIR)
  print(process3.stdout)

# output KUBEADMIN_PASSWORD
with open(KUBEADMIN_PASSWORD_FILE, 'r') as file:
  KUBEADMIN_PASSWORD = file.read().rstrip()

process4 = subprocess.run(['jq', '-r', '.infraID', 'metadata.json'],
                         stdout=subprocess.PIPE,
                         cwd=OPENSHIFT_DIR,
                         text=True)
# output INFRA_ID
INFRA_ID=process4.stdout.strip("\n")
print('INFRA_ID: '+INFRA_ID)

print('Configure bootstrap ignition with hostname: '+INFRA_ID+'-bootstrap')

# Codes from install_upi.md
with open(BOOTSTRAP_IGN_FILE, 'r') as f:
  ignition = json.load(f)

storage = ignition.get('storage', {})
files = storage.get('files', [])

infra_id = INFRA_ID.encode()
hostname_b64 = base64.standard_b64encode(infra_id + b'-bootstrap\n').decode().strip()
files.append(
{
    'path': '/etc/hostname',
    'mode': 420,
    'contents': {
        'source': 'data:text/plain;charset=utf-8;base64,' + hostname_b64,
    },
})

storage['files'] = files
ignition['storage'] = storage

with open(BOOTSTRAP_IGN_FILE, 'w') as f:
    json.dump(ignition, f)

def edit_master_hostname(INFRA_ID, index):
  MASTER_HOSTNAME=INFRA_ID+'-master-'+str(index)+'\n'
  print('Configure master ignition with hostname: '+MASTER_HOSTNAME)
  MASTER_JSON=OPENSHIFT_DIR+'master-'+str(index)+'.ign'
  with open(MASTER_IGN_FILE, 'r') as f:
    ignition_master = json.load(f)
    storage_master = ignition_master.get('storage', {})
    files = storage_master.get('files', [])
    files.append({'path': '/etc/hostname', 'mode': 420, 'contents': {'source': 'data:text/plain;charset=utf-8;base64,' + base64.standard_b64encode(MASTER_HOSTNAME.encode()).decode().strip()}})
    storage_master['files'] = files
    ignition_master['storage'] = storage_master
  with open(MASTER_JSON, 'w') as outfile:
    json.dump(ignition_master, outfile)

for index in range(3):
  edit_master_hostname(INFRA_ID, index)

print('Remove clouds.yml')
process5 = subprocess.run(['rm', '-f', 'clouds.yml'],
                         stdout=subprocess.PIPE,
                         cwd=OPENSHIFT_DIR)