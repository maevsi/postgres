---
applyTo: '**'
---

# Project Instructions

This project builds the PostgreSQL container image of `vibetype`, an event community platform, for the `postgres` and `reccoom-postgres` services of the `stack` repository.

## Image

- PostGIS and pgvector come as packages from the PostgreSQL project's apt repository, which the official Debian based `postgres` image already configures and which builds them for amd64 and arm64
  - The package names follow the base image's `PG_MAJOR`, so a new major installs the matching extensions
  - Their versions follow the repository at build time, so a rebuild can bring a newer PostGIS, after which a database needs `ALTER EXTENSION postgis UPDATE`
- A new PostgreSQL major needs a `pg_upgrade` of every deployed database, so Renovate opens such updates without merging them automatically
- The base stays on Debian: a switch of the C library, as to Alpine, changes the collation of existing databases, which invalidates their text indexes
- A new database gets `postgis` and `postgis_topology` from `docker-entrypoint-initdb.d`, as `sqitch` migrations expect PostGIS to exist

## Release

- semantic-release versions the image from git tags alone, so the repository has no `package.json`

## Verification

- `.github/smoke-test.sh` runs in CI against the built image and checks the extensions; extend it when the image gains a feature
