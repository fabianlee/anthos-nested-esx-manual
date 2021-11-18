#!/bin/bash

# ESXi7 has strict hw requirements and e1000 does not work anymore
# have to use vmxnet3 to get installer to recognize
if qemu-system-x86_64 -net nic,model=? | grep vmxnet3 -q; then
  echo "vmxnet3 is valid NIC type"
else
  echo "vmxnet3 is NOT valid NIC type.  ESXi7 installer does not recognize e1000 or realtek rtl8139"
  exit 1
fi

# default location for esxi installer ISO
iso=~/Downloads/VMware-VMvisor-Installer-7.0U3-18644231.x86_64.iso
if [ -n "$1" ]; then
  iso="$1"
fi

virsh pool-list
disk_pool=data
virsh pool-info $disk_pool

virt-install --virt-type=kvm --name=esxi1 \
--cpu host-passthrough \
--ram 73728 --vcpus=24 \
--virt-type=kvm --hvm \
--cdrom $iso \
--network network:esxmgmt140,model=vmxnet3 \
--network network:admin141,model=vmxnet3 \
--network network:user142,model=vmxnet3 \
--graphics vnc --video qxl \
--disk pool=$disk_pool,size=1500,sparse=true,bus=ide,format=qcow2 \
--boot cdrom,hd,menu=on --noautoconsole --force
