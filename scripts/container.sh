#!/usr/bin/env bash

set -euxETo pipefail

# Compute build directory from any working directory
declare build_dir
build_dir="$(readlink --canonicalize-existing "$(dirname "${BASH_SOURCE[0]}")/..")"
declare -r build_dir

docker buildx build \
  --build-arg DEBIAN_RELEASE=bullseye \
  --build-arg DEFAULT_TOOLCHAIN=stable \
  --build-arg GROUP_ID="$(id --group)" \
  --build-arg USER_ID="$(id --user)" \
  --tag rust-ibverbs \
  "${build_dir}"

docker run \
  --interactive \
  --mount "type=bind,source=${build_dir},target=/rust-ibverbs" \
  --mount "type=volume,src=rust-ibverbs-cargo-cache,destination=/home/builder/.cargo" \
  --mount "type=volume,src=rust-ibverbs-rdma-core-build,destination=/rust-ibverbs/vendor/rdma-core/build" \
  --mount "type=volume,src=rust-ibverbs-target-cache,destination=/rust-ibverbs/target" \
  --name="rust-ibverbs" \
  --network=host \
  --privileged \
  --rm \
  --tty \
  --user "$(id --user):$(id --group)" \
  --workdir "/rust-ibverbs" \
  rust-ibverbs \
  bash
