  
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}

variable "ssh_public_key" {}
variable "ssh_private_key_file" {}

variable cidrs {
    type = map(string)
    default = {
        "vcn" = "10.0.0.0/16"
    }
}

variable "db_password" {}
variable "oci_keys_path" {}
variable "local_ip_address" {}