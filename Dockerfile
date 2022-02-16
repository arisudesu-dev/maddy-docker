FROM golang:1.17.7-alpine3.15 AS build-env

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

FROM alpine:3.15
LABEL maintainer="arisudesu@yandex.ru"

RUN apk --no-cache add ca-certificates
COPY --from=build-env /pkg/data/maddy.conf /etc/maddy/maddy.conf
COPY --from=build-env /pkg/usr/local/bin/maddy /usr/bin/maddy
COPY --from=build-env /pkg/usr/local/bin/maddyctl /usr/bin/maddyctl

EXPOSE 25 143 993 587 465
VOLUME ["/var/lib/maddy"]

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["/usr/bin/maddy"]
