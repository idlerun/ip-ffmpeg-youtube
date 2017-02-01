#!/bin/sh

if [ ! -d /data ]; then
  >&2 echo "Expected Docker mounted volume at /data"
  exit 1
fi
cd /data

while :
do
  echo "Cleaning up old recordings"
  ls -1 /data/*-*-*_*-*-*.mp4 | head -n -48 | xargs rm -vf
  echo "Waiting for 1 hour"
  sleep 3600
done
