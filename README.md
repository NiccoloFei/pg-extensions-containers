# Building PostgreSQL Extensions Container Images

The goal of this project is to build PostgreSQL extensions in the form of
distroless container images. These images can be used in CloudNativePG,
dynamically loading them via the new ImageVolume feature introduced in
Kubernetes 1.33.

# Currrent targets

Each extension is being built against the following targets.

PostgreSQL versions:
- 18beta1

Operating system:
- Debian bookworm
- Debian bullseye

Architectures:
- amd64
- arm64

# Structure of the project

TODO

# Adding new extensions

TODO
