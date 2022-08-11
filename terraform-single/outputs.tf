# log the floating IP for convenience
output "ip" {
  value       = resource.ibm_is_floating_ip.testacc_floatingip.address
  description = "The public IP address of the VSI"
}
