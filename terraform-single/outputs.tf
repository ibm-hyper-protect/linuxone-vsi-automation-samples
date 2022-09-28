# log the floating IPs for convenience
output "primary" {
  value       = resource.ibm_is_floating_ip.testacc_floatingip.address
  description = "The public IP address of primary instance"
}
output "secondary" {
  value       = resource.ibm_is_floating_ip.testacc_floatingip_2.address
  description = "The public IP address of secondary instance"
}
