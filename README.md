# eBPF Playgroud

This project is used to containerize eBPF programs written using cilium/ebpf
and deploy it to kubernetes. It reads the eBPF program from a configmap, and
then compiles it into an executable which is run as a deployment.

## How to use

The project contains a sample eBPF program by default which can be overrided
using the configmap. The default program is present in [`ebpf/pgm/`](/ebpf/pgm/).
The required helpers and headers from libebpf are included in [`ebpf/headers/`](/ebpf/headers/).

The eBPF programs need to follow the following convention to be able to override
the default program,

- The entrypoint of `go` program which starts the eBPF script must be an exported
  function called `Start()`.
- The eBPF program file must be named `ebpf.c` and the go program file should be
  named `ebpf.go`. These names are used to override the default program.

## Limitations

- Dependency management of go programs isn't supports. Any override of the the go
  program that adds new dependencies is not supported currently. Workaround, replace
  the default program and build container from source.
- Additional headers if required, the container will have to be built from source.

## Build from Source

### Local code generation

[`Makefile`](/Makefile) contains `container-all` that can perform the code generation
for eBPF programs in [`ebpf/pgm/`](/ebpf/pgm/).

[`Dockerfile`](/Dockerfile) containerizes the application using the [entrypoint.sh](/entrypoint.sh)
script which contains the logic for overriding the default program.

### Build Image

```bash
$> export REGISTRY=quay.io/thejasn/ebpf-playground
$> make image
```
This builds and pushes the image to the configured registry.

### Deployment

```bash
$> oc create ns ebpf-playground
$> oc apply -f deployment/configmap.yaml
$> oc adm policy add-scc-to-user privileged system:serviceaccount:ebpf-playground:default
$> oc apply -f deployment/deployment.yaml
```
