#!/bin/bash
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && (pwd -W 2> /dev/null || pwd))

set -x
ssh -i $SCRIPT_DIR/tf-kvm-seedvm/id_rsa ubuntu@192.168.140.220
