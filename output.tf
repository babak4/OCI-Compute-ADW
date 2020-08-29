output "VM_public_ip" {
    value = "${oci_core_instance.always_free_01.public_ip}"
}

output "DB_Connection_URLs" {
    value = "${oci_database_autonomous_database.db01.connection_urls}"
}