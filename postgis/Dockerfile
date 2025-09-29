ARG BASE=ghcr.io/cloudnative-pg/postgresql:18-minimal-trixie

FROM $BASE AS builder

ARG PG_MAJOR
ARG EXT_VERSION

USER 0

RUN set -eux; \
	# Initial system libraries
	ldconfig -p | awk '{print $NF}' | grep '^/' | sort | uniq > /tmp/source.out && \
	# Install
	apt-get update && \
	apt-get install -y --no-install-recommends "postgresql-${PG_MAJOR}-postgis-${EXT_VERSION%%.*}=${EXT_VERSION}*" && \
	# Gather postgis-related system libraries
	ldd /usr/lib/postgresql/${PG_MAJOR}/lib/address_standardizer*.so \
	    /usr/lib/postgresql/${PG_MAJOR}/lib/postgis*.so \
		| awk '{print $3}' | grep '^/' | sort | uniq > /tmp/deps.out && \
	grep -Fvx -f /tmp/source.out /tmp/deps.out > /tmp/libraries.out && \
	mkdir -p /opt/syslib && \
	cat /tmp/libraries.out | xargs -I{} cp {} /opt/syslib

FROM scratch

# Lib
COPY --from=builder \
	/usr/lib/postgresql/18/lib/address_standardizer* \
	/usr/lib/postgresql/18/lib/postgis* \
	/lib/
COPY --from=builder /usr/lib/postgresql/18/lib/bitcode/ /lib/bitcode/

# Share
COPY --from=builder \
	/usr/share/postgresql/18/extension/address_standardizer* \
	/usr/share/postgresql/18/extension/postgis* \
	/share/extension/
COPY --from=builder /usr/share/postgresql/18/contrib/postgis* /share/contrib/

# System libs
COPY --from=builder /opt/syslib /syslib/
