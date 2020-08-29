
resource "oci_core_instance" "always_free_01" {
  availability_domain = lookup(data.oci_identity_availability_domains.always_free_ads.availability_domains[0], "name")
  compartment_id      = var.compartment_ocid
  shape               = "VM.Standard.E2.1.Micro"

  create_vnic_details {
    subnet_id      = oci_core_subnet.always_free_sn.id
    display_name   = "always_free_vnic"
    hostname_label = "always-free"
  }
  
  display_name = "always-free-01"

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  source_details {
    #Ubuntu 20.10
    source_id   = "ocid1.image.oc1.uk-london-1.aaaaaaaamnz6jzdyj7yyfeh6vyoydjw4e6eigus6qnwuwh2ugu7agbnnvr5a"
    source_type = "image"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(var.ssh_private_key_file)
  }

  provisioner "file" {
    source      = "scripts/test_connection.py"
    destination = "/tmp/test_connection.py"
  }

  provisioner "file" {
    destination = "/tmp/always_free.ini"
    content     = templatefile("./scripts/config/always_free.ini", { db_password = var.db_password })
  }

  provisioner "file" {
    source      = "${var.oci_keys_path}/oci_api_key_public.pem"
    destination = "/tmp/oci_api_key_public.pem"
  }

  provisioner "file" {
    source      = "${var.oci_keys_path}/oci_api_key.pem"
    destination = "/tmp/oci_api_key.pem"
  }

  provisioner "file" {
    destination = "/tmp/config"
    content     = templatefile("config.tpl", { user = var.user_ocid, fingerprint = var.fingerprint, tenancy = var.tenancy_ocid, region = var.region })
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y build-essential python3-pip python3-venv unzip python-dev libaio-dev libaio1 libfontconfig git net-tools",
      "pip3 install oci-cli",
      "export PATH=/home/ubuntu/.local/bin:$PATH",
      "cd /tmp",
      "sudo -p mkdir /opt/oracle",
      "wget https://download.oracle.com/otn_software/linux/instantclient/19800/instantclient-basiclite-linux.x64-19.8.0.0.0dbru.zip",
      "sudo unzip -o instantclient-basiclite-linux.x64-19.8.0.0.0dbru.zip -d /opt/oracle",
      "echo '. .bashrc' > ~/.bash_profile",
      "echo 'export LD_LIBRARY_PATH=/opt/oracle/instantclient_19_8/' >> ~/.bash_profile",
      "echo 'export TNS_ADMIN=/opt/oracle/instantclient_19_8/network/admin/' >> ~/.bash_profile",
      "echo 'export PATH=/home/ubuntu/.local/bin:$PATH' >> ~/.bash_profile",
      "cd ~",
      "mkdir .oci",
      "cp /tmp/config .oci/",
      "chmod 600 ~/.oci/config",
      "cp /tmp/oci_api_key_public.pem /tmp/oci_api_key.pem .oci/",
      "sudo chmod 600 ~/.oci/oci_api_key.pem",
      "mkdir app",
      "cd app",
      "mv /tmp/test_connection.py .",
      "mv /tmp/always_free.ini .",
      "python3 -m venv .venv",
      ". .venv/bin/activate",
      "pip install cx_oracle configParser",
      "oci db autonomous-database generate-wallet --autonomous-database-id ${oci_database_autonomous_database.db01.id} --password ${var.db_password} --file /tmp/wallet.zip",
      "echo '[ \"${oci_core_instance.always_free_01.public_ip}\", \"${var.local_ip_address}\" ]' > /tmp/adw_whitelisted_ips.json",
      "oci db autonomous-database update --force --autonomous-database-id ${oci_database_autonomous_database.db01.id} --whitelisted-ips file:///tmp/adw_whitelisted_ips.json --wait-for-state AVAILABLE --wait-interval-seconds 5",
      "sudo unzip -o /tmp/wallet.zip -d /opt/oracle/instantclient_19_8/network/admin/",
      "export LD_LIBRARY_PATH=/opt/oracle/instantclient_19_8/",
      "export TNS_ADMIN=/opt/oracle/instantclient_19_8/network/admin/",
      "python test_connection.py",
    ]

  }
}
