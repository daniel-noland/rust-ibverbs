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
  rm --force --recursive /tmp/kernel-source # TODO: ditch this line, it's crazy outside your test env
  mkdir /tmp/kernel-source
  ls -lahR /boot;
  apt-get install --yes linux-modules-extra-azure;
  depmod --all;
  modprobe rdma_rxe;
#
#  (
#    set -x;
#    declare kernel_release
##    kernel_release="$(uname --kernel-release)"
#    kernel_release="5.11.0-1028-azure"
#    declare -r kernel_release
#    declare -r kernel_version="${kernel_release%%-*}"
#    declare -r kernel_maj_min="${kernel_version%.*}"
#
#    pushd /tmp/kernel-source;
#    apt-get source --yes "linux-image-unsigned-${kernel_release}" >/dev/null;
#    ls;
#    pushd "/tmp/kernel-source/linux-azure-${kernel_maj_min}-${kernel_version}";
#    apt-get source --yes "linux-image-unsigned-${kernel_release}";
#    cp "/boot/config-${kernel_release}" ./.config;
#    cp "/usr/src/linux-headers-${kernel_release}/Module.symvers" ./;
#    make olddefconfig;
#    sed --in-place 's/# CONFIG_RDMA_RXE is not set/CONFIG_RDMA_RXE=m/' ./.config;
#    make --jobs="$(nproc)" prepare;
#    make --jobs="$(nproc)" modules_prepare;
#    make --jobs="$(nproc)" scripts/mod;
#    make --jobs="$(nproc)";
#    make --jobs="$(nproc)" modules;
#    make --jobs="$(nproc)" modules_install;
##    modprobe ib_core
##    mkdir --parent "/lib/modules/${kernel_release}/kernel/drivers/infiniband/sw/rxe";
##    cp ./drivers/infiniband/sw/rxe/rdma_rxe.ko "/lib/modules/${kernel_release}/kernel/drivers/infiniband/sw/rxe";
#    depmod --all;
#    modprobe rdma_rxe;
#  )
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