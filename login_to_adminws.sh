#!/bin/bash
BIN_DIR=$(dirname "${BASH_SOURCE[0]}")

set -x
ssh -i $BIN_DIR/needed_on_adminws/gke-admin-workstation ubuntu@192.168.140.221
