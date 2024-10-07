## Deploy Hyper Protect Container Runtime on IBM Cloud Infrastructure Center (ICIC)

### Preparation

1. Setup ICIC Management node and compute nodes [see details](https://www.ibm.com/products/cloud-infrastructure-center) and make sure to have details like username, password, tenant name, authentication URL and domain name.
2. Prepare your environment according to [these steps](../README.md)

### Provision on ICIC

Initialize terraform:

```bash
terraform init
```

Deploy the example:

```bash
terraform apply
```

### Settings

Use one of the following options to set your settings:

#### Template file

1. Copy contents of `my-settings.auto.tfvars-template` to `my-settings.auto.tfvars`.
    ```bash
    cp my-settings.auto.tfvars-template my-settings.auto.tfvars
    ```
2. Update `my-settings.auto.tfvars` to appropriate values.

#### Environment variables

Set the following environment variables:

```text
TF_VAR_icic_username="ICIC username"
TF_VAR_icic_password="ICIC password"
TF_VAR_icic_tenant_name="ICIC tenant name"
TF_VAR_icic_auth_url="ICIC authentication URL"
TF_VAR_icic_domain_name="ICIC domain name"

TF_VAR_prefix = "prefix for names"
TF_VAR_hpvs_image_path = "path to HPVS qcow2"
TF_VAR_icic_network_name = "ICIC network name"
TF_VAR_icic_target_compute_node = "Target compute node to bring up instance"

TF_VAR_logdna_ingestion_key="LogDNA instance key"
TF_VAR_logdna_ingestion_hostname="LogDNA instance hostname"
TF_VAR_hpcr_image_cert_path = "HPCR encryption certificate path"
```

### Run the Example

Initialize terraform:

```bash
terraform init
```

Deploy the example:

```bash
terraform apply
```

#### Test if the example works

Use your browser to access:

```text
http://<IP>
```

This will show a screen like this:

![nginx](images/nginx.png)

Destroy the created resources:

```bash
terraform destroy
```
