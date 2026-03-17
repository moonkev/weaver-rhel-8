# Weaver Build on AlmaLinux 8

This repository provides a Docker/Podman setup to build Weaver v0.22.1 on AlmaLinux 8 (compatible with RHEL 8). To build the Weaver image, run (switch podman with docker if that is what you use):

```bash
podman build -t weaver-build .
```

This uses a multi-stage Dockerfile where the first stage compiles Weaver from source and the second stage produces a minimal image containing only the Weaver binary. After building, you can extract the binary without overwriting container files by creating a temporary container and copying the binary out:

```bash
podman create --name tmp-weaver weaver-build
podman cp tmp-weaver:/weaver/weaver ./weaver
podman rm tmp-weaver
```

The `weaver` binary is now available in your current directory and ready to run on RHEL 8 / AlmaLinux 8 systems. Do not bind-mount `/weaver` into the container during extraction, as this will hide the binary. You can verify the binary works by running:

```bash
./weaver --help
```

Weaver requires Rust, Node.js, and pnpm for building (the UI assets are built during the container build), but the final binary is standalone. The build image includes OpenSSL and Perl development libraries needed for compilation. This Dockerfile produces a clean minimal image containing only the final Weaver binary. This repository follows the license of the Weaver project: [LICENSE](https://github.com/open-telemetry/weaver/blob/v0.22.1/LICENSE).

