# postgres

Vibetype's PostgreSQL container image, which adds [PostGIS](https://postgis.net/) and [pgvector](https://github.com/pgvector/pgvector) to the official [`postgres`](https://hub.docker.com/_/postgres) Alpine image.
It is published for `linux/amd64` and `linux/arm64` as `ghcr.io/maevsi/postgres`.

## Usage

The image is configured like the official `postgres` image.
A new database starts with the `postgis` and `postgis_topology` extensions, like with `postgis/postgis`.
pgvector is installed but not created, so a database that needs it runs `CREATE EXTENSION vector`.

## Development

Build the image with `docker build -t postgres .` and test it with `SMOKE_TEST_IMAGE=postgres .github/smoke-test.sh`.
