# Buildkit gc repro

This repo is to reproduce a possible buildkitd storage leak.

## Requirements
The `./repro.sh` script simply requires a kubernetes cluster/config setup

## Usage

`./repro.sh`

This script should create a kubernetes namespace `buildkit-repro` with a statefulsets for buildkitd and a statefulset + service for a docker registry. Once buildkit and the registry are ready, it will use kubectl cp/exec to build the app in `./testapp` repeatedly, with a small "code" change per build to bust the cache a bit. It should also print out the disk usage reported by `buildctl du` and `df -h` each at the begining and end of the run.
