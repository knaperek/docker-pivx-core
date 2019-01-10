FROM debian:stretch-slim

RUN groupadd -r pivx && useradd -r -m -g pivx pivx

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu wget \
	&& rm -rf /var/lib/apt/lists/*

ENV PIVX_VERSION=3.1.1 \
	PIVX_URL=https://github.com/PIVX-Project/PIVX/releases/download/v3.1.1/pivx-3.1.1-x86_64-linux-gnu.tar.gz \
	PIVX_SHA256=aac5b13beb9ff96b0ce62d2258d54166c756c8336672a67c7aae6b73a76b0c03 \
	PIVX_DATA=/data

# install pivx binaries
RUN set -ex \
	&& cd /tmp \
	&& wget -qO pivx.tar.gz "$PIVX_URL" \
	&& echo "$PIVX_SHA256 pivx.tar.gz" | sha256sum -c - \
	&& tar -xzvf pivx.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt \
	&& rm -rf /tmp/*

# create data directory
RUN mkdir "$PIVX_DATA" \
	&& chown -R pivx:pivx "$PIVX_DATA" \
	&& ln -sfn "$PIVX_DATA" /home/pivx/.pivx \
	&& chown -h pivx:pivx /home/pivx/.pivx

VOLUME /data

COPY docker-entrypoint.sh /entrypoint.sh

USER pivx

ENTRYPOINT ["/entrypoint.sh"]
CMD ["pivxd"]
