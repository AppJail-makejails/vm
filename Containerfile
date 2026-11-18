ARG FREEBSD_RELEASE

FROM ghcr.io/appjail-makejails/base:${FREEBSD_RELEASE}-unstable

ARG NO_PKGCLEAN
ARG IS_TOR

LABEL org.opencontainers.image.title="VM" \
    org.opencontainers.image.description="Makejail for creating virtual machines using vm-bhyve" \
    org.opencontainers.image.source="https://github.com/AppJail-makejails/vm" \
    org.opencontainers.image.url="https://github.com/AppJail-makejails/vm" \
    org.opencontainers.image.vendor="DtxdF" \
    org.opencontainers.image.authors="Jesús Daniel Colmenares Oviedo <dtxdf@disroot.org>"

RUN set -xe; \
    \
    pkg update; \
    extra_packages=; \
    if [ -n "${IS_TOR}" ]; then \
        extra_packages="coredns tor"; \
    fi; \
    pkg install \
        vm-bhyve-devel \
        bhyve-firmware \
        tmux \
        git-tiny \
        jq \
        qemu-tools \
        grub2-bhyve \
        ${extra_packages} \
        FreeBSD-set-base-jail; \
    \
    if [ -z "${NO_PKGCLEAN}" ]; then \
        pkg clean -a; \
        rm -rf /var/cache/pkg/*; \
    fi; \
    rm -rf /var/db/pkg/repos/*

RUN set -xe; \
    \
    cd /; \
    git clone --depth 1 https://github.com/DtxdF/qga-guest-exec.git; \
    (cd qga-guest-exec; env SUEXEC=command ./make.sh); \
    rm -rf qga-guest-exec

COPY vm-exec /usr/local/bin/vm-exec

RUN chmod +x /usr/local/bin/vm-exec
