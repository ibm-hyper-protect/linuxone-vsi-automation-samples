# Deploys web server in zVSI with Ansible

## Preparations

1. Install Python3
2. Install [RedHat Ansible] 2.9+
   - `pip install "ansible>=2.9.2"`
3. Install IBM cloud ansible
   - `ansible-galaxy collection install ibm.cloudcollection`
4. Adjust [ansible settings](group_vars/all.yml)
5. Ensure you have an `IC_API_KEY` environment variable set up with your
   IBM Cloud API key
    - this will likelly require a paying account
    - If you have downloaded your `apikey.json` file from the IBM Cloud UI you may use this command:
      `export IC_API_KEY=$(cat ~/apikey.json | jq -r .apikey)`

## Create

1. `ansible-playbook create.yml`

## Destroy

1. `ansible-playbook destroy.yml`
   - Note: VPC and subnetwork will not be deleted - comment in last two tasks in
     [destroy.yml](destroy.yml) if you want them deleted.
2. Delete `.cache` folder