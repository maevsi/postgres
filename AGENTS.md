---
applyTo: '**'
---

# Project Instructions

This project builds the PostgreSQL container image of `vibetype`, an event community platform, for the `postgres` and `reccoom-postgres` services of the `stack` repository.

## Image

- PostGIS and pgvector are compiled from source in the `build` stage, as `postgis/postgis` publishes no arm64 image
  - The PostGIS build follows the upstream Alpine Dockerfile at https://github.com/postgis/docker-postgis, so compare against it when PostGIS updates
  - pgvector is built with an empty `OPTFLAGS`, as the default `-march=native` would tie the image to the build machine's CPU
- The base stays on Alpine, as a switch to a glibc based image changes the collation of existing databases, which invalidates their text indexes
- The PostgreSQL major stays at 18, as a new major needs a `pg_upgrade` of every deployed database; Renovate is limited accordingly
- A new database gets `postgis` and `postgis_topology` from `docker-entrypoint-initdb.d`, as `sqitch` migrations expect PostGIS to exist

## Verification

- `.github/smoke-test.sh` runs in CI against the built image and checks the extensions; extend it when the image gains a feature
