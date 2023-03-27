# Deploys a client-to-site VPN server (Beta) in VPC with Ansible

This is a sample playbook for generating a client-to-site VPN server on IBM Cloud. This creates a single subnetwork VPC
and deploys a client-to-site VPN server into it. This playbook produces certificates for use by the VPN server and client.
It does not establish separate, by userid, login credentials, so anyone with the resulting ovpn file will be able to
establish a VPN to the environment. Finally this playbook uses the IBM Cloud API to deploy the client-to-site VPN server.
Once the ibm.cloudcollection ansible collection has been enriched to deploy the VPN server, it should be used instead of this
project.

## Preparations

1. Install Python3
2. Install [RedHat Ansible] 2.9+
   - `pip install "ansible>=2.9.2"`
3. Install ansible collections
   - `ansible-galaxy collection install ibm.cloudcollection`
   - `ansible-galaxy collection install community.crypto`
4. Adjust [ansible settings](group_vars/all.yml)
5. Ensure you have an `IC_API_KEY` environment variable set up with your
   IBM Cloud API key
    - this will likely require a paying account
    - you can create an API account by visiting the [IBM Cloud API keys page](https://cloud.ibm.com/iam/apikeys). Ensure you have
      selected the account you want to use before creating the key as the key will be associated to the account you have selected
      at the time of creation.
    - If you have downloaded your `apikey.json` file from the IBM Cloud UI you may use this command:
      `export IC_API_KEY=$(cat ~/apikey.json | jq -r .apikey)`
6. Ensure you have setup the appropriate IAM service-to-service authorizations to allow a client-to-site VPN server to access a
  Certificate Manager. [https://cloud.ibm.com/docs/vpc?topic=vpc-client-to-site-authentication#creating-iam-service-to-service](https://cloud.ibm.com/docs/vpc?topic=vpc-client-to-site-authentication#creating-iam-service-to-service)

## Create

- `ansible-playbook create.yml`

If you want to use a different region add `-e region=<MZR name>` to the above command. Example: `-e region=br-sao`

## Destroy

1. `ansible-playbook destroy.yml`
   - Note: The client-to-site VPN server (Beta), VPC and subnetwork, and Certificate Manager will not be deleted by default - adjust settings in [ansible settings](group_vars/all.yml)
   if you want them deleted.
