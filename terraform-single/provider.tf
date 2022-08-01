variable "ibmcloud_api_key" {
  description = "Enter your IBM Cloud API Key, you can get your IBM Cloud API key using: https://cloud.ibm.com/iam#/apikeys"
}

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = ">= 1.43.0"
    }
  }
}

# Configure the IBM Provider
provider "ibm" {
  ibmcloud_api_key      = var.ibmcloud_api_key
  region = var.region
}