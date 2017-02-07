#!/bin/sh

if [ "$#" -lt 1 ]; then
  >&2 echo "Required arguments: YOUTUBE_STREAM_NAME"
  exit 1
fi

if [ ! -d /data ]; then
  >&2 echo "Expected Docker mounted volume at /data"
  exit 1
fi
cd /data

YOUTUBE_STREAM_NAME=$1

>&2 echo "YOUTUBE_STREAM_NAME=$YOUTUBE_STREAM_NAME"

while :
do
  echo "Checking for recording to upload"
  # unchecked mp4 files except the most recent (currently being written) 
  FILE=$(ls -1 /data/*-*-*_*-*-*.mp4 | grep -v DONE | head -n -1 | head -n 1)
  if [ "X$FILE" != "X" ]; then
    echo "Found $FILE to upload"
    ffmpeg \
      -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 \
      -r 1800 -i "$FILE" \
      -shortest \
      -map 0:a:0 -c:a aac -b:a 16k \
      -filter:v "fps=60" \
      -map 1:v:0 -c:v libx264 -preset superfast -b:v 1000k \
      -f flv rtmp://a.rtmp.youtube.com/live2/$YOUTUBE_STREAM_NAME

    # avoid being detected again by pattern
    mv "$FILE" "$FILE-DONE.mp4"
  else
    echo "Waiting for 1 minute"
    sleep 60
  fi
done
