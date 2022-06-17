# The development version of clang is distributed as the 'clang' binary,
# while stable/released versions have a version number attached.
# Pin the default clang to a stable version.
CLANG ?= clang-14

# Prefer podman if installed, otherwise use docker.
# Note: Setting the var at runtime will always override.
CONTAINER_ENGINE ?= $(if $(shell command -v podman), podman, docker)
CONTAINER_RUN_ARGS ?= $(if $(filter ${CONTAINER_ENGINE}, podman),, --user "${UIDGID}")

REPODIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

IMAGE := quay.io/cilium/ebpf-builder
VERSION := 1648566014

# Build all ELF binaries using a containerized LLVM toolchain.
container-all:
	${CONTAINER_ENGINE} run --rm ${CONTAINER_RUN_ARGS} \
		-v "${REPODIR}":/ebpf-grpc -w /ebpf-grpc --env MAKEFLAGS \
		--env CFLAGS="-fdebug-prefix-map=/ebpf-grpc=." \
		--env HOME="/tmp" \
		"${IMAGE}:${VERSION}" \
		$(MAKE) generate

# (debug) Drop the user into a shell inside the container as root.
container-shell:
	${CONTAINER_ENGINE} run --rm -ti \
		-v "${REPODIR}":/ebpf -w /ebpf \
		"${IMAGE}:${VERSION}"

# $BPF_CLANG is used in go:generate invocations.
generate: export BPF_CLANG := $(CLANG)
generate: export BPF_CFLAGS := $(CFLAGS)
generate:
	cd ebpf/ && go generate ./...
