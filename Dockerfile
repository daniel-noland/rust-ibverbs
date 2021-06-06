ARG DEBIAN_RELEASE=bullseye
FROM debian:${DEBIAN_RELEASE}-slim as base

RUN apt-get update \
 && apt-get install --yes --no-install-recommends \
 bash \
 ca-certificates \
 clang \
 cmake \
 curl \
 cython3 \
 docutils-common \
 git \
 iproute2 \
 jq \
 libdrm-dev \
 libibverbs-dev \
 libnl-3-dev \
 libnl-genl-3-dev \
 libnl-route-3-dev \
 libsystemd-dev \
 libudev-dev \
 llvm \
 ninja-build \
 pandoc \
 pkg-config \
 python `#unfortunately python2 still seems to be required for cmake to build rdma-core` \
 python3 \
 sudo \
 valgrind \
 && apt-get --yes clean

FROM base as user

ARG USER_ID
ARG GROUP_ID
RUN mkdir -p /home/builder \
 && groupadd --non-unique --gid "${GROUP_ID}" builder \
 && useradd --non-unique --uid "${USER_ID}" --gid "${GROUP_ID}" --home-dir /home/builder builder \
 && chown -R builder:builder /home/builder \
 && mkdir --parent /rust-ibverbs/vendor/rdma-core/build \
 && mkdir --parent /rust-ibverbs/target \
 && chown --recursive builder:builder /rust-ibverbs/vendor/rdma-core/build \
 && chown --recursive builder:builder /rust-ibverbs/target \
 && echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

FROM user as rust
USER builder
ADD --chown=builder:builder https://sh.rustup.rs /rustup.rs
RUN sh -- /rustup.rs -y
ENV PATH="/home/builder/.cargo/bin:${PATH}"
RUN rustup toolchain install stable \
 && rustup toolchain install beta \
 && rustup toolchain install nightly \
 && sudo chown --recursive builder:builder /home/builder/.cargo

ARG DEFAULT_TOOLCHAIN=stable
RUN rustup default "${DEFAULT_TOOLCHAIN}"

VOLUME ["/home/builder/.cargo", "/rust-ibverbs/vendor/rdma-core/build", "/rust-ibverbs/target"]
