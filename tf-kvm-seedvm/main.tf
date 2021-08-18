
# list of hosts to be created, use 'for_each' on relevant resources
locals {
  seedvm = {
    "seedvm" = { os_code_name = "focal", network = "esxmgmt140", prefixIP = "192.168.140", octetIP = "220", vcpu=4, memoryMB=1024*4, incGB=200 }
  }
}

# fetch the latest ubuntu release image from their mirrors
resource "libvirt_volume" "os_image" {
  for_each = local.seedvm

  name = "${each.key}.qcow2"
  pool = var.diskPool
  source = "https://cloud-images.ubuntu.com/${each.value.os_code_name}/current/${each.value.os_code_name}-server-cloudimg-amd64${ each.value.os_code_name == "xenial" ? "-disk1":"" }.img"
  format = "qcow2"
}

#
# since an Ubuntu cloud image is non-LVM, cannot extend rootFS with second disk
# so we extend using qemu-img, and then use the cloud_init file to grow the primary partition
resource "null_resource" "extend_primary_volume" {
  depends_on = [ libvirt_volume.os_image ]
  for_each = local.seedvm

  provisioner "local-exec" {
    command = <<EOF
      echo "going to wait 10 seconds before trying to increment disk size by ${each.value.incGB}GB"
      sleep 10
      poolPath=$(virsh pool-dumpxml ${var.diskPool} | grep -Po '<path>\K[^<]+')
      sudo qemu-img resize $poolPath/${each.key}.qcow2 +${each.value.incGB}G
    EOF
  }
}


# Use CloudInit ISO to add ssh-key to the instance
resource "libvirt_cloudinit_disk" "cloudinit" {
  for_each = local.seedvm

  name = "${each.key}-cloudinit.iso"
  pool = var.diskPool
  user_data = data.template_file.user_data[each.key].rendered
  network_config = data.template_file.network_config[each.key].rendered
}


data "template_file" "user_data" {
  for_each = local.seedvm

  template = file("${path.module}/cloud_init.cfg")
  vars = {
    hostname = each.key
    fqdn = "${each.key}.${var.dns_domain}"
    password = var.password
  }
}

data "template_file" "network_config" {
  for_each = local.seedvm

  template = file("${path.module}/network_config_${var.ip_type}.cfg")
  vars = {
    domain = var.dns_domain
    prefixIP = each.value.prefixIP
    octetIP = each.value.octetIP
  }
}

# Create the machine
resource "libvirt_domain" "domain-ubuntu" {
  depends_on = [ null_resource.extend_primary_volume ]
  for_each = local.seedvm

  # domain name in libvirt, not hostname
  name = "${each.key}-${each.value.prefixIP}.${each.value.octetIP}"
  memory = each.value.memoryMB
  vcpu = each.value.vcpu

  disk { volume_id = libvirt_volume.os_image[each.key].id }

  network_interface {
       network_name = each.value.network
  }

  cloudinit = libvirt_cloudinit_disk.cloudinit[each.key].id

  # IMPORTANT
  # Ubuntu can hang is a isa-serial is not present at boot time.
  # If you find your CPU 100% and never is available this is why
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = "true"
  }
}

output "hosts_1_network" {
  value = libvirt_domain.domain-ubuntu["seedvm"].network_interface[*]
}
output "hosts" {
  # output does not support 'for_each', so use zipmap as workaround
  value = zipmap( 
                values(libvirt_domain.domain-ubuntu)[*].name,
                values(libvirt_domain.domain-ubuntu)[*].vcpu
                )
}
