# example of creating local routed networks, meaning routing happens outside KVM
# which typically means you need to add static routes on your upstream router sending packets back to host
#
# list of networks to be created
locals {
  networks = {
    "esxmgmt140" = { mode="route", address="192.168.140.0/24", domain="home.lab", dns_forwarder="127.0.0.1"},
    "admin141" =   { mode="route", address="192.168.141.0/24", domain="home.lab", dns_forwarder="127.0.0.1"},
    "user142" =    { mode="route", address="192.168.142.0/24", domain="home.lab", dns_forwarder="127.0.0.1"},
  }
}

# https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/network 
resource "libvirt_network" "routed" {
  for_each = local.networks
  name = each.key
  # nat|none|route|bridge
  mode = each.value.mode
  addresses = [ each.value.address ]

  domain = each.value.domain
  dns {
    enabled = true
    local_only = false
    forwarders { address= each.value.dns_forwarder }
  }
  dhcp { enabled = false }
  autostart = true
}


