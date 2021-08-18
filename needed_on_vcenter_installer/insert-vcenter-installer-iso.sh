#!/bin/bash

vm=seedvm-192.168.140.220

cdrom=`virsh domblklist $vm --details | grep cdrom | awk {'print $3'}`
currentISO=`virsh domblklist $seedvm --details | grep cdrom | awk {'print $4'}`

# eject current
virsh change-media $vm $cdrom $currentISO --eject

# inject vcenter installer ISO
virsh change-media $vm $cdrom /data/VMware-VCSA-all-6.7.0-16708996_u3j.iso --insert

