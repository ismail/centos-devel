# syntax=docker/dockerfile:1.4

FROM quay.io/centos/centos:stream9-development

RUN echo "install_weak_deps=False" >> /etc/dnf/dnf.conf
RUN dnf install -y \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
    https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-9.noarch.rpm

RUN dnf update -y && dnf clean all

RUN dnf --allowerasing install --setopt=tsflags=nodocs \
        bsdtar ca-certificates clang clang-tools-extra compiler-rt cpio \
        curl gcc gcc-c++ gdb git golang iproute less libasan \
        llvm mtr openssl python3 openssh-clients procps \
        rpm sudo strace vim zsh zstd -y && \
    dnf clean all && rm -f /root/*.log && rm -rf /root/*.cfg

ARG GOSU_VERSION=1.14
ARG TARGETPLATFORM

RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then ARCHITECTURE=amd64; elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then ARCHITECTURE=arm64; fi \
    && curl -sS -L https://github.com/tianon/gosu/releases/download/"$GOSU_VERSION"/gosu-"$ARCHITECTURE" | install /dev/stdin /usr/local/bin/gosu

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

COPY files/ /
RUN  chmod 0755 /entrypoint
ENTRYPOINT ["/entrypoint"]
