#!/bin/bash

if [[ $# -lt 1 ]]; then
  echo "Usage: <fullPathTo-VMware-VCSA.iso>"
  echo "Example: /data/VMware-VCSA-all-6.7.0-16708996_u3j.iso"
  exit 1
fi
vcsa_iso="$1"

vm="seedvm-192.168.140.220"

cdrom=$(virsh domblklist $vm --details | grep cdrom | awk '{print $3}')
currentISO=$(virsh domblklist $vm --details | grep cdrom | awk '{print $4}')
echo $vm current cdrom $cdrom with iso loaded $currentISO

set -x
virsh change-media $vm $cdrom $currentISO --eject

# inject vcenter installer ISO
virsh change-media $vm $cdrom "$vcsa_iso" --insert

