# syntax=docker/dockerfile:1

# PostGIS is compiled here instead of using `postgis/postgis`, which publishes no arm64 image.
# The build follows https://github.com/postgis/docker-postgis/blob/master/18-3.7/alpine/Dockerfile, without its regression tests.

########################
# Provide the base.

FROM postgres:18.7-alpine3.24@sha256:ff64c9e3bdf8e2120107d3559de8db314e8305f7e38c5105903c6295876738ff AS base


########################
# Compile the extensions.

FROM base AS build

# renovate: datasource=github-tags depName=postgis/postgis
ENV POSTGIS_VERSION=3.7.0
# renovate: datasource=github-tags depName=pgvector/pgvector
ENV PGVECTOR_VERSION=v0.8.7

ADD https://github.com/postgis/postgis.git#${POSTGIS_VERSION} /usr/src/postgis
ADD https://github.com/pgvector/pgvector.git#${PGVECTOR_VERSION} /usr/src/pgvector

# `DOCKER_PG_LLVM_DEPS` names the clang and llvm versions that the base image's PostgreSQL was built with, which its JIT bitcode needs.
RUN apk add --no-cache \
      $DOCKER_PG_LLVM_DEPS \
      autoconf \
      automake \
      file \
      g++ \
      gcc \
      gdal-dev \
      geos-dev \
      gettext-dev \
      gmp-dev \
      json-c-dev \
      libtool \
      libxml2-dev \
      make \
      pcre2-dev \
      perl \
      proj-dev \
      protobuf-c-dev \
      sfcgal-dev

WORKDIR /usr/src/postgis

RUN gettextize \
    && ./autogen.sh \
    && ./configure --enable-lto \
    && make -j"$(nproc)" \
    && make install DESTDIR=/srv/extensions

WORKDIR /usr/src/pgvector

# An empty `OPTFLAGS` drops `-march=native`, which would tie the build to the CPU of the machine building it.
RUN make OPTFLAGS="" \
    && make install DESTDIR=/srv/extensions


########################
# Serve the database.

FROM base AS production

RUN apk add --no-cache \
      ca-certificates \
      gdal \
      geos \
      gmp \
      json-c \
      libstdc++ \
      pcre2 \
      proj \
      protobuf-c \
      sfcgal

COPY --from=build /srv/extensions/usr/local /usr/local
