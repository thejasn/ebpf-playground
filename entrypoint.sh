#!/usr/bin/env bash

rm /src/ebpf/pgm/epbf.*

cp -R /src/ebpf.* /src/ebpf/pgm/

make generate

cd /src/ebpf && go build -o /main ./cmd/main.go && cd /

./main

