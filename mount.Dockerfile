FROM alpine:latest

ENV RCLONE_VERSION="1.46"

RUN adduser -h /rclone -s /sbin/nologin -D -u 1000 app \
    && mkdir -p /rclone/tmp

RUN apk add --no-cache ca-certificates fuse \
    && wget -O /tmp/rclone.zip https://github.com/ncw/rclone/releases/download/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-amd64.zip \
    && unzip -d /rclone/tmp/ /tmp/rclone.zip \
    && mv /rclone/tmp/*/* /rclone/tmp/ \
    && mv /rclone/tmp/rclone /rclone/rclone \
    && rm -r /rclone/tmp/ /tmp/rclone.zip \
    && chmod 500 /rclone/rclone \
    && chown app:app -R /rclone

# container metadata
WORKDIR /config
USER app
ENTRYPOINT ["/rclone/rclone"]
