#!/bin/sh
set -eu

# Like `postgis/postgis`, a new database starts with PostGIS, which migrations expect to exist already.
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-'EOSQL'
	CREATE EXTENSION IF NOT EXISTS postgis;
	CREATE EXTENSION IF NOT EXISTS postgis_topology;
EOSQL
