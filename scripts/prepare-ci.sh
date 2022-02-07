#!/usr/bin/env bash

set -euxETo pipefail

# Activate deb-src archives
sed --in-place 's/^# deb-src/deb-src/' /etc/apt/sources.list

apt-get update

apt-get install --yes --no-install-recommends \
  dpkg-dev \
;

# Install kernel build dependencies
install_kernel_build_dependencies() {

  apt-get build-dep --yes --no-install-recommends \
   linux-azure \
  ;

  # build-dep install isn't very reliable.  It misses these packages.
  apt-get install --yes --no-install-recommends \
    bc \
    bison \
    flex \
    libelf-dev \
    libssl-dev \
    ncurses-dev \
  ;
}

build_and_install_soft_roce_kernel_module() {
  uname -a;
  uname --kernel-release;
  mkdir --parent /tmp/kernel-source
  (
    set -x;
    pushd /tmp/kernel-source;
    apt-get source --yes "linux-image-unsigned-$(uname --kernel-release)" >/dev/null;
    ls;
    pushd "/tmp/kernel-source/linux-azure-5.11-5.11.0";
#    apt-get source --yes "linux-image-unsigned-5.4.0-1010-azure";
#    pushd "/tmp/kernel-source/linux-azure-5.4.0";
    apt-cache search linux-buildinfo | grep azure;
    apt-get install --yes "linux-buildinfo-$(uname --kernel-release)"
#    apt-get install --yes "linux-buildinfo-5.4.0-1010-azure";
    cp "/usr/lib/linux/$(uname --kernel-release)/config" ./.config;
#    cp "/usr/lib/linux/5.4.0-1010-azure/config" ./.config;
    make olddefconfig;
#    cp "/usr/src/linux-headers-5.11.0-1028-azure/Module.symvers" ./;
    cp "/usr/src/linux-headers-$(uname --kernel-release)/Module.symvers" ./;
    sed --in-place 's/# CONFIG_RDMA_RXE is not set/CONFIG_RDMA_RXE=m/' ./.config;
    make --jobs="$(nproc)" prepare;
    make --jobs="$(nproc)" modules_prepare;
    make --jobs="$(nproc)" drivers/infiniband/core/ib_core.ko;
    make --jobs="$(nproc)" drivers/infiniband/sw/rxe/rdma_rxe.ko;
    modprobe ib_core
    cp ./drivers/infiniband/core/ib_core.ko /lib/modules/;
    insmod ./drivers/infiniband/sw/rxe/rdma_rxe.ko;
#    cp "/usr/src/linux-headers-$(uname --kernel-release)-1010-azure/Module.symvers" ./;
  )
}

# Install rdma libs
install_rdma_libs() {
  apt-get install --yes --no-install-recommends \
    libibverbs-dev \
    libnl-3-dev \
    libnl-route-3-dev \
    rdma-core \
  ;
}

install_kernel_build_dependencies
build_and_install_soft_roce_kernel_module