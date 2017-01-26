#!/bin/sh

if [ "$#" -ne 2 ]; then
  >&2 echo "Required arguments: IP_CAMERA_ADDRESS YOUTUBE_STREAM_NAME"
  exit 1
fi

if [ ! -d /data ]; then
  >&2 echo "Expected Docker mounted volume at /data"
  exit 1
fi
cd /data

IP_CAMERA_ADDRESS=$1
YOUTUBE_STREAM_NAME=$2

>&2 echo "IP_CAMERA_ADDRESS=$IP_CAMERA_ADDRESS"
>&2 echo "YOUTUBE_STREAM_NAME=$YOUTUBE_STREAM_NAME"

## YouTube will not accept a stream without audio, even if there is none
## Getting audio from /dev/zero to fill it in with something

exec ffmpeg -thread_queue_size 128 -i \
    $IP_CAMERA_ADDRESS \
  -re -ar 44100 -ac 2 -c:a pcm_s16le -f s16le -ac 2 -i /dev/zero -f h264 \
  -c:a aac -b:a 16k -g 50 -strict experimental \
  -vcodec libx264 -preset veryfast -crf 30 -vf "fps=30" \
  -f flv \
    rtmp://a.rtmp.youtube.com/live2/$YOUTUBE_STREAM_NAME \
  -f segment -reset_timestamps 1 -segment_time 3600 -segment_format mp4 -segment_atclocktime 1 -strftime 1 \
    "%Y-%m-%d_%H-%M-%S.mp4"
