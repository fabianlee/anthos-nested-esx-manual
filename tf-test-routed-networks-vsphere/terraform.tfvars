vsphere_user          = "Administrator@vsphere.local"
vsphere_password      = "ExamplePass@456"
vsphere_server        = "vcenter.home.lab"
vsphere_datacenter    = "mydc1"

vsphere_datasource    = "datastore1"
vsphere_cluster       = ""
vsphere_network       = "pgAdmin"
vsphere_template      = "ubuntu20"

jumphost_name         = "test141"
jumphost_password     = "password"
jumphost_domain       = "home.lab"
jumphost_cpu          = "1"
jumphost_ram_mb       = "1024"
jumphost_disk_gb      = "50"

jumphost_ip           = "192.168.141.30"
jumphost_subnet       = "24"
jumphost_gateway      = "192.168.141.1"

jumphost_vm_folder    = "" # empty if wanted in root

dns_server_list       = [ "192.168.141.1" ]
dns_suffix_list       = [ "home.lab" ]


