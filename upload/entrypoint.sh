#!/bin/sh

if [ "$#" -lt 2 ]; then
  >&2 echo "Arguments: IP_CAMERA_ADDRESS LIVE_ID [TIMELAPSE_ID]"
  exit 1
fi

if [ ! -d /data ]; then
  >&2 echo "Expected Docker mounted volume at /data"
  exit 1
fi
cd /data

IP_CAMERA_ADDRESS=$1
LIVE_ID=$2

>&2 echo "IP_CAMERA_ADDRESS=$IP_CAMERA_ADDRESS"
>&2 echo "LIVE_ID=$LIVE_ID"

## Note: YouTube will not accept a stream without audio, even if there is none
## Getting audio from /dev/zero to fill it in with something

if [ "$#" -gt 2 ]; then
  TIMELAPSE_ID=$3
  >&2 echo "TIMELAPSE_ID=$TIMELAPSE_ID"
  exec ffmpeg \
    -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 \
    -thread_queue_size 128 -i $IP_CAMERA_ADDRESS \
    -shortest \
    -vf "fps=30" \
    -map 0:a:0 -c:a aac -b:a 16k \
    -map 1:v:0 -c:v libx264 -preset veryfast -g 90 -x264opts no-scenecut -b:v 1000k \
    -f flv rtmp://a.rtmp.youtube.com/live2/$LIVE_ID \
    -f segment -reset_timestamps 1 -segment_time 600 -segment_format mp4 -segment_atclocktime 1 -strftime 1 \
      "%Y-%m-%d_%H-%M-%S.mp4" \
    -f mpegts - | ffmpeg \
      -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 \
      -thread_queue_size 128 -f mpegts -r 1200 -i - \
      -shortest \
      -map 0:a:0 -c:a aac -b:a 16k \
      -map 1:v:0 -c:v libx264 -preset veryfast -g 1 -x264opts no-scenecut -b:v 1000k \
      -f flv rtmp://a.rtmp.youtube.com/live2/$TIMELAPSE_ID
else
  exec ffmpeg \
    -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 \
    -thread_queue_size 128 -i $IP_CAMERA_ADDRESS \
    -shortest \
    -vf "fps=30" \
    -map 0:a:0 -c:a aac -b:a 16k \
    -map 1:v:0 -c:v libx264 -preset veryfast -g 90 -x264opts no-scenecut -b:v 1000k \
    -f flv rtmp://a.rtmp.youtube.com/live2/$LIVE_ID \
    -f segment -reset_timestamps 1 -segment_time 600 -segment_format mp4 -segment_atclocktime 1 -strftime 1 \
      "%Y-%m-%d_%H-%M-%S.mp4"
fi


# for no recoding, just direct stream forward from camera
# doesn't seem to work with the segmented files though..
#  exec ffmpeg \
#    -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 \
#    -thread_queue_size 128 -i $IP_CAMERA_ADDRESS \
#    -map 0:a -c:a aac -b:a 16k -map 1:v -c:v copy -f flv rtmp://a.rtmp.youtube.com/live2/$YOUTUBE_STREAM_NAME \
#    -an -map 1:v -c:v copy -f segment -reset_timestamps 1 -segment_time 3600 -segment_format mp4 -segment_atclocktime 1 -strftime 1 "%Y-%m-%d_%H-%M-%S.mp4"

