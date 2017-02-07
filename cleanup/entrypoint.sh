#!/bin/sh

if [ ! -d /data ]; then
  >&2 echo "Expected Docker mounted volume at /data"
  exit 1
fi
cd /data

while :
do
  date
  echo "Cleaning up old recordings"
  ls -1 /data/*-*-*_*-*-*.mp4 | head -n -288 | xargs rm -vf
  echo "Waiting for 1 minute"
  sleep 60
done
