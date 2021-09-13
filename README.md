# LinuxONE automation

Ansible/Terraform examples for IBM Cloud LinuxONE VSIs. Each of them are stand-alone so pick up
the closes for your needs. Also do not hesistate to contribure new examples.

These are not created with any direct usage in production but as base for your own.

## Ansible or Terraform

IBM Cloud ansible is implemented as Terraform wrapper so they both basically
allow you to create any IaaS/PaaS/SaaS in the IBM Cloud.

Ansible will also allow you to do more actions such as installing SW on created
LinuxONE VSI. Also Ansible will, in general, tolerate that you have created parts of the
infrastructure manually without having to import it as in Terraform´s case.

Therefore, in general I preffer Ansible over Terraform BUT if you are only creating
infrastructure and it is a large project (such as creating multiple VSIs for OCP)
then Terraform will be faster. This is because Terraform is aware of the dependencies
and will try to create more things in parallel.

## More info

- [IBM Cloud ansible collection](https://github.com/IBM-Cloud/ansible-collection-ibm)
- [IBM Cloud Terraform plugin](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs)
