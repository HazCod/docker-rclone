FROM alpine:latest AS builder

ENV RCLONE_VERSION="1.46"

RUN mkdir /rclone \
    && echo -e "root:x:0:0:root:/root:/sbin/nologin\napp:x:1000:1000:,,,:/rclone:/sbin/nologin" > /rclone/passwd \
    && echo -e "root:!::0:::::\napp:!:17987:0:99999:7:::" > /rclone/shadow \
    && echo -e "root:x:0:root\napp:x:1000:app" > /rclone/group

RUN apk add --no-cache ca-certificates \
    && wget -O /tmp/rclone.zip https://github.com/ncw/rclone/releases/download/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-amd64.zip \
    && unzip -d /rclone/ /tmp/rclone.zip \
    && mv /rclone/*/* /rclone/ \
    && rm /tmp/rclone.zip \
    && chmod 500 /rclone/rclone

FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /rclone/passwd /rclone/shadow /rclone/group /etc/
COPY --from=builder --chown=app:app /rclone/rclone /rclone
USER app
ENTRYPOINT ["/rclone"]
