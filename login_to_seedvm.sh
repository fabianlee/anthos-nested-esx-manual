#!/bin/bash
BIN_DIR=$(dirname "${BASH_SOURCE[0]}")

set -x
ssh -i $BIN_DIR/tf-kvm-seedvm/id_rsa ubuntu@192.168.140.220
