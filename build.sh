#!/bin/bash -e
cd $(dirname $0)

pushd upload >/dev/null
docker build -t youtube-live-stream .
popd >/dev/null

pushd download >/dev/null
docker build -t youtube-live-download .
popd >/dev/null

pushd cleanup >/dev/null
docker build -t youtube-live-cleanup .
popd >/dev/null