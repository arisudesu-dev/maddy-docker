FROM golang:1.16.5-alpine3.14 AS build-env

COPY maddy /maddy/
WORKDIR /maddy/

ENV LDFLAGS=-static
RUN apk --no-cache add bash git gcc musl-dev

RUN mkdir /pkg/
COPY maddy/maddy.conf /pkg/data/maddy.conf
# Monkey-patch config to use environment.
RUN sed -Ei 's!\$\(hostname\) = .+!$(hostname) = {env:MADDY_HOSTNAME}!' /pkg/data/maddy.conf
RUN sed -Ei 's!\$\(primary_domain\) = .+!$(primary_domain) = {env:MADDY_DOMAIN}!' /pkg/data/maddy.conf
RUN sed -Ei 's!^tls .+!tls file /etc/maddy/certs/tls_cert.pem /etc/maddy/certs/tls_key.pem!' /pkg/data/maddy.conf

RUN ./build.sh --builddir /tmp --destdir /pkg/ build install

FROM alpine:3.14.0
LABEL maintainer="arisudesu@yandex.ru"

RUN apk --no-cache add ca-certificates
COPY --from=build-env /pkg/data/maddy.conf /etc/maddy/maddy.conf
COPY --from=build-env /pkg/usr/local/bin/maddy /usr/bin/maddy
COPY --from=build-env /pkg/usr/local/bin/maddyctl /usr/bin/maddyctl

EXPOSE 25 143 993 587 465
VOLUME ["/var/lib/maddy"]

# There is no entrypoint, but there is default shell command
# to allow executing `maddy` and `maddyctl` from docker run.
CMD ["/usr/bin/maddy"]
