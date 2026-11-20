# syntax=docker/dockerfile:1

FROM postgres:18.7-trixie@sha256:eb63372c1e05c755f55fa30cbd07aecc443676fc6c0fa90b9002d01537841e1a AS production

# The base image ships the PostgreSQL project's apt repository, which builds both extensions for every architecture.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      "postgresql-${PG_MAJOR}-pgvector" \
      "postgresql-${PG_MAJOR}-postgis-3" \
      "postgresql-${PG_MAJOR}-postgis-3-scripts" \
    && rm -rf /var/lib/apt/lists/*

COPY ./docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
