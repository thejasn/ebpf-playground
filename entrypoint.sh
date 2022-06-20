#!/usr/bin/env bash


if [ -f /src/go/ebpf.go ] && [ -f /src/c/ebpf.c ]; then
    rm /src/ebpf/pgm/ebpf.*
    rm -f /src/ebpf/pgm/bpf_.*
    echo "$(cat /src/go/ebpf.go)" > /src/ebpf/pgm/ebpf.go
    echo "$(cat /src/c/ebpf.c)" > /src/ebpf/pgm/ebpf.c
fi

make generate

cd /src/ebpf && go build -o /main ./cmd/main.go && cd /

/main

