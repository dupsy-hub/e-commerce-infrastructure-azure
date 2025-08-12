# output "vmss_ids" {
#   value = module.vmss.vmss_ids
# }

# output "vmss_names" {
#   value = module.vmss.vmss_names
# }

# output "vmss_instance_counts" {
#   value = module.vmss.vmss_instance_counts
# }

# output "vmss_locations" {
#   value = module.vmss.vmss_locations
# }

#--- sql ---
output "sql_server_name" {
  value       = module.azure_sql.sql_server_name
  description = "The name of the SQL Server"
}

output "sql_server_fqdn" {
  value       = module.azure_sql.sql_server_fqdn
  description = "FQDN of the SQL Server for client connections"
}

output "sql_database_name" {
  value       = module.azure_sql.sql_database_name
  description = "The name of the SQL Database"
}

output "sql_server_id" {
  value       = module.azure_sql.sql_server_id
  description = "Resource ID of the SQL Server"
}
