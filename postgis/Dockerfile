ARG BASE=ghcr.io/cloudnative-pg/postgresql:18rc1-minimal-trixie

FROM $BASE AS builder

ARG PG_MAJOR=18
ARG EXT_VERSION=master

USER 0

RUN set -eux; \
	ldconfig -p | awk '{print $NF}' | grep '^/' | sort | uniq > /tmp/source.out && \
	mkdir -p /opt/extension && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		"postgresql-server-dev-${PG_MAJOR}" \
		git \
		automake \
		bison \
		build-essential \
		ca-certificates \
		cmake \
		docbook-xml \
		docbook5-xml \
		libboost-all-dev \
		libcunit1-dev \
		libcurl4-gnutls-dev \
		libgmp-dev \
		libjson-c-dev \
		libmpfr-dev \
		libprotobuf-c-dev \
		libsqlite3-dev \
		libtiff-dev \
		libtool \
		libxml2-dev \
		libxml2-utils \
		pkg-config \
		protobuf-c-compiler \
		xsltproc \
		libproj-dev \
		libpq5 \
		libgdal-dev \
		libgeos-dev \
		libsfcgal-dev \
	&& \
	git clone -b "${EXT_VERSION}" --single-branch https://github.com/postgis/postgis.git /tmp/postgis && \
	cd /tmp/postgis && \
	./autogen.sh && \
	./configure --with-pgconfig=/usr/lib/postgresql/${PG_MAJOR}/bin/pg_config --prefix=/opt/extension/ --with-sfcgal && \
	make -j$(nproc) && \
	make install && \
	make install datadir=/opt/extension/share/ pkglibdir=/opt/extension/lib/ && \
	ldd /opt/extension/lib/*.so | awk '{print $3}' | grep '^/' | sort | uniq > /tmp/deps.out && \
	grep -Fvx -f /tmp/source.out /tmp/deps.out > /tmp/libraries.out && \
	mkdir -p /opt/extension/syslib && \
	cat /tmp/libraries.out | xargs -I{} cp {} /opt/extension/syslib

FROM scratch

COPY --from=builder /opt/extension/bin/ /bin/
COPY --from=builder /opt/extension/lib/ /lib/
COPY --from=builder /opt/extension/share/ /share/
COPY --from=builder /opt/extension/syslib/ /syslib/
