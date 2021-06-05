FROM debian:bullseye-slim as build

RUN apt-get update \
 && apt-get install --yes --no-install-recommends \
 bash \
 ca-certificates \
 clang \
 cmake \
 curl \
 git \
 iproute2 \
 libnl-3-dev \
 libnl-genl-3-dev \
 libnl-route-3-dev \
 libsystemd-dev \
 llvm \
 ninja-build \
 pkg-config \
 python \
 python3 \
 sudo

ARG USER_ID
ARG GROUP_ID
RUN mkdir -p /home/builder \
 && groupadd --non-unique --gid "${GROUP_ID}" builder \
 && useradd --non-unique --uid "${USER_ID}" --gid "${GROUP_ID}" --home-dir /home/builder builder \
 && chown -R builder:builder /home/builder \
 && mkdir --parent /rust-ibverbs/vendor/rdma-core/build \
 && mkdir --parent /home/builder/.cargo \
 && chown --recursive builder:builder /rust-ibverbs/vendor/rdma-core/build \
 && chown --recursive builder:builder /home/builder/.cargo

RUN echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER builder
ADD --chown=builder:builder https://sh.rustup.rs /rustup.rs
RUN sh -- /rustup.rs -y
ENV PATH="/home/builder/.cargo/bin:${PATH}"
RUN rustup toolchain install stable \
 && rustup toolchain install beta \
 && rustup toolchain install nightly

ARG DEFAULT_TOOLCHAIN=stable
RUN rustup default "${DEFAULT_TOOLCHAIN}"

VOLUME ["/home/builder/.cargo", "/rust-ibverbs/vendor/rdma-core/build"]
