FROM debian:stretch-slim as builder

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates wget

ENV PIVX_VERSION=3.3.0
ENV PIVX_URL=https://github.com/PIVX-Project/PIVX/releases/download/v$PIVX_VERSION/pivx-$PIVX_VERSION-x86_64-linux-gnu.tar.gz \
	PIVX_SHA256=ee01caf0cc1aba794aa1d1eb9daf156c489f037c1b870a81c6528d74fcd75f17

RUN set -ex \
	&& cd /tmp \
	&& wget -qO pivx.tar.gz "$PIVX_URL" \
	&& echo "$PIVX_SHA256 pivx.tar.gz" | sha256sum -c - \
	&& tar -xzvf pivx.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt


FROM debian:stretch-slim
COPY --from=builder /usr/local/bin/pivxd /usr/local/bin/pivx-cli /usr/local/bin/
RUN groupadd -r pivx && useradd -r -m -g pivx pivx \
	&& ln -s /usr/local/bin/pivx-cli /usr/local/bin/c

ENV PIVX_DATA=/data

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
