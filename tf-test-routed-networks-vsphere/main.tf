# example of creating routed networks and placing vms on each at kvm level
# 

# list of hosts to be created, use 'for_each' on relevant resources
locals {
  testvm = {
    "vsphere140" = { template="ubuntu20-focal", network = "VM Network", prefixIP = "192.168.140", octetIP = "51", vcpu=1, memoryMB=1024*1 },
    "vsphere141" = { template="ubuntu20-focal", network = "admin141", prefixIP = "192.168.141", octetIP = "51", vcpu=1, memoryMB=1024*1 },
    "vsphere142" = { template="ubuntu20-focal", network = "user142", prefixIP = "192.168.142", octetIP = "51", vcpu=1, memoryMB=1024*1 },
  }
}


data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}


data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datasource
  datacenter_id = data.vsphere_datacenter.dc.id
}
# unfortunately, providering datastore cluster name to vm resource is not possible
#data "vsphere_datastore_cluster" "datastore_cluster" {
#  name          = var.vsphere_datasource
#  datacenter_id = data.vsphere_datacenter.dc.id
#}


#
# resource_pool_id can either come from cluster or from esxi host
#
data "vsphere_compute_cluster" "cluster" {
  count         = var.vsphere_cluster=="" ? 0:1
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_host" "esxihost" {
  count         = var.vsphere_cluster=="" ? 1:0
  # name not needed if there is only 1 esxi host
  datacenter_id = data.vsphere_datacenter.dc.id
}


data "vsphere_network" "network" {
  for_each = local.testvm

  name          = each.value.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  for_each = local.testvm

  name          = each.value.template
  datacenter_id = data.vsphere_datacenter.dc.id
}


resource "vsphere_virtual_machine" "vm" {
  for_each = local.testvm

  #name             = var.jumphost_name
  name             = "${each.key}-${each.value.prefixIP}.${each.value.octetIP}"

  # resource pool id comes from cluster or esxi host
  resource_pool_id = var.vsphere_cluster=="" ? data.vsphere_host.esxihost[0].resource_pool_id:data.vsphere_compute_cluster.cluster[0].resource_pool_id
#  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
#  resource_pool_id = data.vsphere_host.esxihost.resource_pool_id

  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.jumphost_vm_folder
  # unfortunately providing datastore cluster name or member is not possible
  #datastore_id     = data.vsphere_datastore_cluster

  # can use these if vmtools agent will not respond with client IP and fails
  #wait_for_guest_net_routable = false
  #wait_for_guest_net_timeout = 0
  #wait_for_guest_ip_timeout = 3

  memory = each.value.memoryMB
  num_cpus = each.value.vcpu

  
  guest_id = data.vsphere_virtual_machine.template[each.key].guest_id
  scsi_type = data.vsphere_virtual_machine.template[each.key].scsi_type

  network_interface {
    network_id   = data.vsphere_network.network[each.key].id
    adapter_type = data.vsphere_virtual_machine.template[each.key].network_interface_types[0]
  }

  disk {
     label            = "disk0"
     unit_number      = 0
     #size             = var.jumphost_disk_gb # expand template disk, but needs role 'lvm_fill_volume'
     size             = data.vsphere_virtual_machine.template[each.key].disks.0.size
     eagerly_scrub    = data.vsphere_virtual_machine.template[each.key].disks.0.eagerly_scrub
     thin_provisioned = data.vsphere_virtual_machine.template[each.key].disks.0.thin_provisioned
  }

  cdrom { 
    client_device = true
  }

  # shows up as device /dev/sdb (lsblk) but will need to be formatted and mounted with role 'extend_lvm_volumes'
#  disk {
#     label            = "disk1"
#     unit_number      = 1
#     datastore_id     = data.vsphere_datastore.datastore.id
#     size             = 140
#     eagerly_scrub    = false
#     thin_provisioned = true
#  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template[each.key].id

    customize {
      linux_options {
        host_name = each.key
        domain    = var.jumphost_domain
      }

      network_interface {
        ipv4_address = "${each.value.prefixIP}.${each.value.octetIP}"
        ipv4_netmask = var.jumphost_subnet
      }

      ipv4_gateway = "${each.value.prefixIP}.1"
      dns_server_list = [ "${each.value.prefixIP}.1" ]
      dns_suffix_list = var.dns_suffix_list
    }
  }

}

output "routed_networks" {
  value = zipmap(
                values(vsphere_virtual_machine.vm)[*].name,
                values(vsphere_virtual_machine.vm)[*].network_interface[*]
                )
}
output "hosts" {
  # output does not support 'for_each', so use zipmap as workaround
  value = zipmap(
                values(vsphere_virtual_machine.vm)[*].name,
                values(vsphere_virtual_machine.vm)[*].num_cpus
                )
}

