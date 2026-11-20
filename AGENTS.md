---
applyTo: '**'
---

# Project Instructions

This project builds the PostgreSQL container image of `vibetype`, an event community platform, for the `postgres` and `reccoom-postgres` services of the `stack` repository.

## Image

- PostGIS and pgvector are compiled from source in the `build` stage, as `postgis/postgis` publishes no arm64 image and Alpine's own packages lag behind the PostGIS version in use
  - The PostGIS build follows the upstream Alpine Dockerfile at https://github.com/postgis/docker-postgis, so compare against it when PostGIS updates
  - pgvector is built with an empty `OPTFLAGS`, as the default `-march=native` would tie the image to the build machine's CPU
  - The arm64 build compiles under emulation and takes about 25 minutes in CI
- The base stays on Alpine, as a switch of the C library changes the collation of existing databases, which invalidates their text indexes
- Renovate tracks PostGIS and pgvector through the `# renovate:` comments in the `Dockerfile`, and does not merge updates automatically that need care:
  - a new PostgreSQL major needs a `pg_upgrade` of every deployed database
  - a new PostGIS major renames its library, so existing databases fail until they are upgraded; a minor only needs `SELECT postgis_extensions_upgrade()` at some point
  - pgvector is still on 0.x, where a minor may break as much as a major
- A new database gets `postgis` and `postgis_topology` from `docker-entrypoint-initdb.d`, as `sqitch` migrations expect PostGIS to exist
  - pgvector is only installed, as the services that use it create it in their own migrations, which also reach existing databases

## Release

- semantic-release versions the image from git tags alone, so the repository has no `package.json`

## Verification

- `.github/smoke-test.sh` runs in CI against the built image and checks the extensions; extend it when the image gains a feature
