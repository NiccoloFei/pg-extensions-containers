ARG BASE=ghcr.io/cloudnative-pg/postgresql:18beta1-minimal-bookworm

FROM $BASE AS builder

ARG PG_MAJOR=18
ARG EXT_VERSION=master

USER 0

RUN set -eux; \
	mkdir -p /opt/extension && \
	apt-get update && \
	apt-get install -y --no-install-recommends git build-essential clang-16 llvm-16-dev "postgresql-server-dev-${PG_MAJOR}" && \
	git clone -b "${EXT_VERSION}" --single-branch https://github.com/pgvector/pgvector.git /tmp/pgvector && \
	cd /tmp/pgvector && \
	make clean && \
	make OPTFLAGS="" && \
	make install datadir=/opt/extension/share/ pkglibdir=/opt/extension/lib/

FROM scratch

COPY --from=builder /opt/extension/lib/ /lib/
COPY --from=builder /opt/extension/share/ /share/