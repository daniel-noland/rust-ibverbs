#!/usr/bin/env bash

set -euxETo pipefail

declare build_dir
build_dir="$(dirname "$(readlink --canonicalize-existing "${BASH_SOURCE[0]}")")"
declare -r build_dir

docker buildx build \
  --build-arg DEFAULT_TOOLCHAIN=stable \
  --build-arg GROUP_ID="$(id --group)" \
  --build-arg USER_ID="$(id --user)" \
  --tag rust-ibverbs \
  "${build_dir}"

docker run \
  --cap-add NET_ADMIN \
  --interactive \
  --mount "type=bind,source=${build_dir},target=/rust-ibverbs" \
  --mount "type=volume,src=rust-ibverbs-rdma-core-build,destination=/rust-ibverbs/vendor/rdma-core/build" \
  --mount "type=volume,src=rust-ibverbs-cargo-cache,destination=/home/builder/.cargo" \
  --name="rust-ibverbs" \
  --rm \
  --tty \
  --user "$(id --user):$(id --group)" \
  --workdir "/rust-ibverbs" \
  rust-ibverbs \
  bash