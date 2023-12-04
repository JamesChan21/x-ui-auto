FROM golang:latest AS builder
WORKDIR /root
COPY . .
RUN go build main.go


FROM debian:12-slim
RUN apt-get update && apt-get install -y --no-install-recommends -y ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
WORKDIR /root
COPY --from=builder  /root/main /root/x-ui
COPY bin/. /root/bin/.
VOLUME [ "/etc/x-ui" ]
RUN echo 'DOCKER_OPTS="--ipv6=false"' >> /etc/default/docker
CMD [ "./x-ui" ]
