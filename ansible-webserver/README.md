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
    - you can create an API account by visiting the [IBM Cloud API keys page](https://cloud.ibm.com/iam/apikeys). Ensure you have
      selected the account you want to use before creating the key as the key will be associtated to the account you have selected
      at the time of creation.
    - If you have downloaded your `apikey.json` file from the IBM Cloud UI you may use this command:
      `export IC_API_KEY=$(cat ~/apikey.json | jq -r .apikey)`

## Create

- **zLinux**: `ansible-playbook create.yml`
- **z/OS**: `ansible-playbook create.yml -e os_type=zos` **NOTE**: limited availability.

If you want to use a different region add `-e region=<MZR name>` to the above command. Example: `-e region=br-sao`

## Destroy

1. `ansible-playbook destroy.yml`
   - Note: VPC and subnetwork will not be deleted - comment in last two tasks in
     [destroy.yml](destroy.yml) if you want them deleted.