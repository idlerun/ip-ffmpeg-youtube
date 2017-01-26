#!/bin/bash

docker tag youtube-live-stream idlerun/youtube-live-stream
docker tag youtube-live-cleanup idlerun/youtube-live-cleanup
#docker tag youtube-live-download idlerun/youtube-live-download

docker push idlerun/youtube-live-stream
docker push idlerun/youtube-live-cleanup
#docker push idlerun/youtube-live-download