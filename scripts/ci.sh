#!/usr/bin/env bash
# This is the script run by CI.

set -euxETo pipefail

# Define the name of the SoftRoCE device we would like to create for integration testing.
declare -r RXE_INTERFACE_NAME="rust_ibverbs"

sudo modprobe rdma_rxe
sudo ./scripts/make-rdma-loopback.sh "${RXE_INTERFACE_NAME}"
