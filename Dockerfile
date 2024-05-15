FROM alpine:3.7

ARG SERVER_BLOCK
ENV SERVER_BLOCK=$SERVER_BLOCK
ARG ENABLE_ALL_PLUGINS

ARG OPENKORE_VER_COMMIT=1edc50f32460846e3a9d9ea58a523fb631b1ab6d

RUN mkdir -p /opt/openkore \
  && apk update \
  && apk add --no-cache git build-base g++ perl perl-dev perl-time-hires perl-compress-raw-zlib readline readline-dev ncurses-libs ncurses-terminfo-base ncurses-dev python2 curl curl-dev nano dos2unix mysql-client bind-tools \
  && git clone https://github.com/openkore/openkore.git /opt/openkore \
  && ln -s /usr/lib/libncurses.so /usr/lib/libtermcap.so \
  && ln -s /usr/lib/libncurses.a /usr/lib/libtermcap.a \
  && cd /opt/openkore/ \
  && git reset --hard "${OPENKORE_VER_COMMIT}" \
  && make -j 6 \
  && mkdir -p /opt/openkore/plugins/automap

RUN apk add bash

WORKDIR /opt/openkore

COPY openkore/plugins/automap/automap.pl /opt/openkore/plugins/automap/automap.pl
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh

CMD ["/opt/openkore/openkore.pl"]

ENTRYPOINT ["/docker-entrypoint.sh"]
