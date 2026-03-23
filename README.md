# xcover-build

Docker image for building [xcover](https://github.com/maxgio92/xcover).

Based on `golang:bookworm` with the full BPF toolchain pre-installed:

- clang / llvm
- libbpf (headers + static link deps)
- bpftool (built from source)
- linux-libc-dev

## Usage

```
ghcr.io/maxgio92/xcover-build:latest
```

### Runtime requirement

`/sys/kernel/btf/vmlinux` must be bind-mounted from the host so bpftool can
generate `vmlinux.h` at build time:

```sh
docker run -v /sys/kernel/btf:/sys/kernel/btf:ro ghcr.io/maxgio92/xcover-build:latest
```

## Updates

- Base Go image and bpftool version are bumped automatically via Renovate.
- A weekly scheduled build picks up apt package updates.
