FROM debian:buster-slim

RUN set -ex \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        build-essential \
        git \
        autoconf \
        automake \
        libtool \
        libasound2-dev \
        libpopt-dev \
        libconfig-dev \
        avahi-daemon \
        libavahi-client-dev \
        libssl-dev

RUN set -ex \
  && git clone https://github.com/mikebrady/shairport-sync.git \
  && cd shairport-sync \
  && autoreconf -fi \
  && ./configure \
              --with-stdout \
              --with-avahi \
              --with-ssl=openssl \
              --with-metadata \
  && make -j $(nproc) \
  && make install

FROM debian:buster-slim

COPY 	--from=0 /usr/local/etc/shairport-sync* /usr/local/etc/
COPY 	--from=0 /usr/local/bin/shairport-sync /usr/local/bin/

RUN set -ex \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        libpopt0 \
        libconfig9 \
        avahi-daemon \
        libssl1.1 \
        libnss-mdns \
        curl \
        alsa-utils

ARG SNAPCASTVERSION=0.27.0
ARG SNAPCAST_FILE="0.27.0-1"

RUN set -ex \
 && curl -L -o 'snapserver_'$SNAPCAST_FILE'_amd64.deb' 'https://github.com/badaix/snapcast/releases/download/v'$SNAPCASTVERSION'/snapserver_'$SNAPCAST_FILE'_amd64.deb' \
 && dpkg -i --force-all 'snapserver_'$SNAPCAST_FILE'_amd64.deb' \
 && apt -f install -y \
   # Clean-up
 && apt-get purge --auto-remove -y \
        curl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache \
 && rm  'snapserver_'$SNAPCAST_FILE'_amd64.deb'

RUN set -ex \
 && mkdir -p /var/lib/snapserver/.config/snapcast/

ENV HOME=/var/lib/snapserver
RUN set -ex \
 && chown snapserver:snapserver -R $HOME \
 && chmod go+rwx -R $HOME

#USER snapserver
COPY entrypoint.sh /usr/local/bin/

ENTRYPOINT /usr/local/bin/entrypoint.sh
