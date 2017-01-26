FROM jrottenberg/ffmpeg
MAINTAINER Idle Run <me@idle.run>
ADD entrypoint.sh /entrypoint.sh
RUN apt-get update && apt-get install -y wget python && \
    wget https://yt-dl.org/downloads/latest/youtube-dl -O /usr/local/bin/youtube-dl && \
    chmod a+rx /usr/local/bin/youtube-dl && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt
ENTRYPOINT /entrypoint.sh $@
