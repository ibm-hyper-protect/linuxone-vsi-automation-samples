# Deploys a single zVSI with Terraform

## Preparations

1. [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
2. `cp my-settings.auto.tfvars-template my-settings.auto.tfvars`
3. Adjust [my-settings.auto.tfvars](my-settings.auto.tfvars)
   - set `ibmcloud_api_key=<your API key>.
      - this will likelly require a paying account
      - you can create an API account by visiting the [IBM Cloud API keys page](https://cloud.ibm.com/iam/apikeys). Ensure you have
        selected the account you want to use before creating the key as the key will be associtated to the account you have selected
        at the time of creation.
      - If you have downloaded your `apikey.json` file from the IBM Cloud UI you may use this command:
        `export IC_API_KEY=$(cat ~/apikey.json | jq -r .apikey)`
   - set `os_type=zos` to deploy a z/OS instance
   - set `region=<MZR>` to use a different region. Example `region=br-sao`
4. `terraform init`

## Create

1. `terraform apply`

## Destroy

1. `terraform destroy`