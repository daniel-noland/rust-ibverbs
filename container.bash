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
  --mount "type=bind,source=${HOME}/.cargo,target=/home/builder/.cargo" \
  --mount "type=bind,source=${build_dir},target=${build_dir}" \
  --name="rust-ibverbs" \
  --rm \
  --tty \
  --user "$(id --user):$(id --group)" \
  --workdir "${build_dir}" \
  rust-ibverbs \
  bash