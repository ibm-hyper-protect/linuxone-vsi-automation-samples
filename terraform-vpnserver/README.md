# Deploys a VPN Server with Terraform

This is a sample Terraform configuration for generating a client-to-site VPN server on IBM Cloud. This creates a single subnetwork VPC
and deploys a client-to-site VPN server into it. This configuration produces certificates for use by the VPN server and client and stores them in an IBM Cloud Secrets Manager instance (free plan). It does not establish separate, by userid, login credentials, so anyone with the resulting certificate file will be able to
establish a VPN to the environment. Thanks to now archived [Helpers for Secrets Manager](https://github.com/we-work-in-the-cloud/terraform-ibm-secrets-manager) for samples on how to import certificates. Once the IBM Terraform provider has been enriched to import certificates directly, it should be used instead of this project.

## Preparations

1. [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
2. `cp my-settings.auto.tfvars-template my-settings.auto.tfvars`
3. Adjust [my-settings.auto.tfvars](my-settings.auto.tfvars)
   - set `ibmcloud_api_key=<your API key>.`
      - this will likely require a paying account
      - you can create an API account by visiting the [IBM Cloud API keys page](https://cloud.ibm.com/iam/apikeys). Ensure you have
        selected the account you want to use before creating the key as the key will be associtated to the account you have selected
        at the time of creation.
      - If you have downloaded your `apikey.json` file from the IBM Cloud UI you may use this command:
        `export IC_API_KEY=$(cat ~/apikey.json | jq -r .apikey)`
   - set `region=<MZR>` to use a different region. Example `region=br-sao`
4. Make sure your IAM polices allow for the IBM Cloud VPN Server to read Secret Manager resources. [https://cloud.ibm.com/docs/vpc?topic=vpc-client-to-site-authentication#creating-iam-service-to-service](https://cloud.ibm.com/docs/vpc?topic=vpc-client-to-site-authentication#creating-iam-service-to-service)
5. `terraform init`

## Create

You must run the create in two phases as the URL of the Secrets Manager must be set once the resource is created and cannot be determined beforehand.

1. `terraform apply -target=module.phase1`
2. `terraform apply`

## Destroy

1. `terraform destroy`
