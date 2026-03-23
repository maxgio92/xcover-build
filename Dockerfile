# xcover-build
#
# Build image for xcover.
# Extends the official Go image with the full BPF toolchain.
#
# Build args
#   GO_VERSION      - Go image tag suffix (default: bookworm = latest Go on Debian bookworm)
#   BPFTOOL_VERSION - libbpf/bpftool git tag (e.g. v7.3.0)
#
# Runtime requirement
#   /sys/kernel/btf/vmlinux must be bind-mounted from the host so that
#   bpftool can generate vmlinux.h at build time:
#     docker run -v /sys/kernel/btf:/sys/kernel/btf:ro ...

# Global build args (must be declared before any FROM to be usable in FROM)
ARG GO_VERSION=bookworm
ARG BPFTOOL_VERSION=v7.3.0

# -----------------------------------------------------------------------------
# Stage 1 — build bpftool
# Kept separate so the source tree and build artifacts don't land in the
# final image.
# -----------------------------------------------------------------------------
FROM debian:bookworm-slim AS bpftool-builder

# Re-declare to bring into stage scope
ARG BPFTOOL_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        ca-certificates \
        gcc \
        make \
        pkg-config \
        libelf-dev \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 \
        --branch "${BPFTOOL_VERSION}" \
        --recurse-submodules \
        https://github.com/libbpf/bpftool.git /tmp/bpftool \
    && cd /tmp/bpftool/libbpf/src \
    && make install \
    && ldconfig \
    && cd /tmp/bpftool/src \
    && make \
    && make install-bin \
    && rm -rf /tmp/bpftool

# -----------------------------------------------------------------------------
# Stage 2 — final image
# Go toolchain + BPF build deps + bpftool binary from stage 1.
# -----------------------------------------------------------------------------
# Re-declare to bring into stage scope
ARG GO_VERSION
FROM golang:${GO_VERSION}

# Runtime deps for bpftool (libelf1, zlib1g) are pulled in transitively by
# libelf-dev and zlib1g-dev below, so no separate install needed.
RUN apt-get update && apt-get install -y --no-install-recommends \
        # BPF C compilation
        clang \
        llvm \
        # libbpf static link deps
        libelf-dev \
        zlib1g-dev \
        # libbpf headers
        libbpf-dev \
        # User-space kernel headers (linux/bpf.h etc.)
        linux-libc-dev \
        # Build toolchain
        gcc \
        make \
        pkg-config \
        git \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=bpftool-builder /usr/local/sbin/bpftool /usr/local/sbin/bpftool

# Smoke-test
RUN bpftool version
