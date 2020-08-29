resource "oci_database_autonomous_database" "db01" {
    admin_password = var.db_password
    compartment_id = var.compartment_ocid
    cpu_core_count = 1
    data_storage_size_in_tbs = 1
    db_name = "ADW01"
    db_workload = "DW"
    display_name = "ADW01"

    is_auto_scaling_enabled = "false"
    is_data_guard_enabled = "false"
    is_dedicated = "false"
    is_free_tier = "true"
    # whitelisted_ips = [""]

}

data "oci_database_autonomous_databases" "autonomous_data_warehouses" {
  compartment_id = var.compartment_ocid
}

output "autonomous_data_warehouse_high_connection_string" {
  value = "${lookup(oci_database_autonomous_database.db01.connection_strings.0.all_connection_strings, "high", "unavailable")}"
}
