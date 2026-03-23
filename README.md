# xcover-build

Docker image for building [xcover](https://github.com/maxgio92/xcover).

Based on `golang:bookworm` with the full BPF toolchain pre-installed:

- clang / llvm
- libbpf (headers + static link deps)
- bpftool (built from source)
- linux-libc-dev

## Usage

From the xcover repo root:

```sh
docker run --rm -it \
  --user $(id -u):$(id -g) \
  -e GOCACHE=/workspace/.cache/go-build \
  -v /sys/kernel/btf:/sys/kernel/btf:ro \
  -v $PWD:/workspace \
  -w /workspace \
  ghcr.io/maxgio92/xcover-build:latest sh
```

Then inside the container:

```sh
make xcover
```

### Notes

- `--user $(id -u):$(id -g)` runs as your host uid so bind-mounted files are writable.
- `-e GOCACHE=/workspace/.cache/go-build` gives Go a writable cache directory.
- `/sys/kernel/btf` must be bind-mounted from the host so bpftool can generate `vmlinux.h`.

## Updates

- Base Go image and bpftool version are bumped automatically via Renovate.
- A weekly scheduled build picks up apt package updates.
