resource "oci_core_vcn" "always_free_vcn" {
    compartment_id = var.compartment_ocid
    cidr_block = lookup(var.cidrs, "vcn")
    display_name = "always-free-vcn"
    dns_label = "free"
}

data "oci_identity_availability_domains" "always_free_ads" {
    compartment_id = var.compartment_ocid
}

resource "oci_core_subnet" "always_free_sn" {
    cidr_block = cidrsubnet(oci_core_vcn.always_free_vcn.cidr_block, 8, 1)
    display_name = "always-free-01"
    dns_label = "freesub01"
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.always_free_vcn.id
    availability_domain = lookup(data.oci_identity_availability_domains.always_free_ads.availability_domains[0], "name")
    security_list_ids = [oci_core_security_list.always_free_sl.id]
    route_table_id = oci_core_route_table.always_free_rt.id
}

data "oci_core_subnets" "always_free_subnets" {
    #Required
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.always_free_vcn.id
}

resource "oci_core_internet_gateway" "always_free_ig" {
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.always_free_vcn.id
    display_name = "always-free-ig"
}

resource "oci_core_route_table" "always_free_rt"{
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.always_free_vcn.id
    display_name = "always-free-rt"
    
    route_rules {
        destination = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
        network_entity_id = oci_core_internet_gateway.always_free_ig.id
    }
}

resource "oci_core_security_list" "always_free_sl" {
  compartment_id = var.compartment_ocid
  display_name   = "always-free-SL"
  vcn_id         = oci_core_vcn.always_free_vcn.id

  egress_security_rules {
      destination = "0.0.0.0/0"
      protocol = "all"
  }

  ingress_security_rules {
      protocol = "6"
      source   = "${var.local_ip_address}/32"

      tcp_options {
        min = 22
        max = 22
      }
  }    

  ingress_security_rules {
    protocol = "1"
    source = "${var.local_ip_address}/32"
  }
}

data "oci_core_security_lists" "always_free_sls" {
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.always_free_vcn.id
}
