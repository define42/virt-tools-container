# virt-tools

A Fedora-based container with `libguestfs` and QEMU utilities for modifying
virtual machine disk images in CI.

This image is built for the
[`rocky9-desktop-cloud-image` workflow](https://github.com/define42/rocky9-desktop-cloud-image/blob/main/.github/workflows/go.yml).
It avoids installing `guestfs-tools` every time that workflow runs.

## Image

```text
ghcr.io/define42/virt-tools-container
```

Available tags:

- `latest` — the most recent successful build from `main`.
- `sha-<commit>` — a build pinned to a full Git commit SHA.
- `run-<run-id>-<attempt>` — a unique image for each workflow execution.

Use a `sha-` or `run-` tag when the consumer needs a reproducible toolchain.

## Included tools

- `guestfs-tools`, including `virt-customize` and `virt-sparsify`
- `qemu-img`
- `wget`, `curl`, and `e2fsprogs`

`LIBGUESTFS_BACKEND` is set to `direct`. The `passt` executable is disabled so
libguestfs falls back to QEMU SLIRP networking inside Docker.

## Use from the Rocky 9 image workflow

The container replaces the Fedora container and package-install commands in the
`Extend cloud image with libguestfs 1.60+` step:

```yaml
- name: Extend cloud image with libguestfs 1.60+
  run: |
    docker_args=(
      --rm
      --volume "$GITHUB_WORKSPACE:/workspace"
      --workdir /workspace
    )

    if [[ -e /dev/kvm ]]; then
      docker_args+=(--device /dev/kvm)
    fi

    docker run "${docker_args[@]}" \
      ghcr.io/define42/virt-tools-container:latest \
      bash -euxo pipefail -c '
        virt-customize \
          -a Rocky-9-GenericCloud-Base.latest.x86_64.qcow2 \
          --commands-from-file run-command.virt
        virt-sparsify \
          --in-place Rocky-9-GenericCloud-Base.latest.x86_64.qcow2
      '
```

This repository is public. Once the GHCR package is also set to public, the
consuming workflow can pull the image without logging in. GitHub manages
repository and package visibility separately.

## Publishing

The [release workflow](.github/workflows/release-container.yml) builds and
publishes the image on every push to `main`. It can also be started manually
with `workflow_dispatch`.
