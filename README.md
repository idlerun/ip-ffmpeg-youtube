---
page: https://idle.run/ip-ffmpeg-youtube
title: IP Camera FFMPEG to YouTube Live with Docker
tags: ip-camera, youtube, ffmpeg, docker
date: 2017-01-25
---

This article is a followup to [ip-camera-stream](https://idle.run/ip-camera-stream) which used Open Broadcasting Studio for streaming video upload. In the updated version we will be running using FFMPEG directly inside of a Docker container. This allows for an ideal headless server setup.


## Sanity Check: FFMPEG performance in Docker

We want to run this in Docker, but first lets do a sanity check to see if FFMPEG has any major performance issues running inside Docker.

### Running FFMPEG in Docker

```
time docker run -v $(pwd):/src -w /src --rm -it jrottenberg/ffmpeg -i test.mp4 -c:v libx264 -f null /dev/null
```

```
real  0m24.793s
```

### Running a local, custom-compiled FFMPEG

```
time ffmpeg -i test.mp4 -c:v libx264 -f null /dev/null
```

```
real  0m23.881s
```

No crazy performance loss there, so we can go ahead.



## Step 1: Camera
Need an IP Camera with RTSP support. I used the "JOOAN 703ERC-T".
Make reference to [iSpy Devices](https://www.ispyconnect.com/sources.aspx) for information about camera support


## Step 2: Configure Camera
This varies by device. For my camera specifically:

- Device had a hard coded IP address of 192.168.1.57. I needed to change my network to the 192.168.1.X range to be able to access it.
- Installed the Device Management software that came with the camera
- Used the device manager to change the camera networking settings to my normal internal network range.


## Step 3: Video Stream Test

Make reference again to [iSpy Devices](https://www.ispyconnect.com/sources.aspx) for RTMP address to use for your device.

Important note: The RMTP address will need to be changed if it includes a username/password that doesn't match that of your camera.

The address for my device is `rtsp://192.168.56.23/user=admin_password=_channel=1_stream=0.sdp`

Open the RTSP address in VLC media player or `ffplay` and it should stream your camera video


## Step 4: Youtube Live
Sign up for [Youtube Live](https://www.youtube.com/live_dashboard) and create a new Live Event.

Private must be either Public or Unlisted to allow for the Stream Keepalive periodic download job which comes later.

Be sure to enable DVR mode if you want to be able to go back up to 4 hrs in your YouTube live history.


## Step 5: Stream Upload

Your live event Injestion Settings page will provide your (secret) Stream Name, for example: `p1tt-db3b-11xv-5a1n`

Modify the command below to insert your own IP Camera RTSP Address and YouTube Stream Name:

```
docker run --restart=always -v ~/recordings:/data -d --name stream-upload idlerun/youtube-live-stream -- rtsp://192.168.56.23/user=admin_password=_channel=1_stream=0.sdp p1tt-db3b-11xv-5a1n
```

Depending on the IP camera being used, it may or may not be needed to actually transcode the media stream from the camera. Ideally the stream can just be directly forwarded to YouTube. This is the default. If the steam needs to be recoded the extra argument `--recode` should be added to the docker cli like so:

```
docker run --restart=always -v ~/recordings:/data -d --name stream-upload idlerun/youtube-live-stream -- rtsp://192.168.56.23/user=admin_password=_channel=1_stream=0.sdp p1tt-db3b-11xv-5a1n --recode
```


## Step 6: Periodic Download (Optional)

If there are no viewers on a stream, YouTube will eventually stop processing the stream input traffic. This means that joining the stream later and going back in the DVR history will not work correctly.

To avoid this happening we can run a job which periodically streams the video for us.

To keep the load as low as possible, it is streaming at the lowest available resolution and only for 5 seconds to ping YouTube to keep the stream from timing out.

```
docker run --restart=always -v ~/recordings:/data -d --name stream-download idlerun/youtube-live-download -- https://www.youtube.com/watch?v=YOURVIDEOID
```


## Step 7: Recording Cleanup (Optional)

The `youtube-live-cleanup` container mounts the `recordings` directory and periodically (every hour) removes all but the most recent 48 recordings (retain 48 hours of video).

```
docker run --restart=always -v ~/recordings:/data -d --name stream-cleanup idlerun/youtube-live-cleanup
```

## Notes:
- The `~/recordings` path could (and probably should) be moved to a directory which is automatically backed up off-site.
