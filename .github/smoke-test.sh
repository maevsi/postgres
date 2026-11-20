#!/usr/bin/env bash
set -euo pipefail

IMAGE="${SMOKE_TEST_IMAGE:?SMOKE_TEST_IMAGE not set}"
CONTAINER="smoke-postgres-${GITHUB_RUN_ID:-$$}-${GITHUB_RUN_ATTEMPT:-1}"

trap 'docker rm --force "$CONTAINER" >/dev/null 2>&1 || true' EXIT

docker run --detach --name "$CONTAINER" \
  -e POSTGRES_DB=smoke \
  -e POSTGRES_PASSWORD=postgres \
  "$IMAGE"

query() {
  docker exec "$CONTAINER" psql -U postgres -d smoke -v ON_ERROR_STOP=1 -tAc "$1"
}

# The entrypoint serves init scripts from a temporary server first, so only a query on the final server proves readiness.
for i in $(seq 1 60); do
  if docker logs "$CONTAINER" 2>&1 | grep -q 'PostgreSQL init process complete' && query 'SELECT 1' >/dev/null 2>&1; then
    echo "PostgreSQL is ready after ${i}s"
    break
  fi
  sleep 1
done

fail() {
  echo "$1"
  docker logs "$CONTAINER"
  exit 1
}

query 'CREATE EXTENSION postgis' >/dev/null || fail 'PostGIS is not installed'
query 'CREATE EXTENSION vector' >/dev/null || fail 'pgvector is not installed'

DISTANCE="$(query "SELECT round(ST_Distance(ST_Point(9.48, 51.31, 4326)::geography, ST_Point(11.58, 48.14, 4326)::geography) / 1000)")"
echo "Distance from Kassel to Munich: ${DISTANCE} km"
[ "$DISTANCE" = '384' ] || fail 'Unexpected geography distance'

VECTOR_DISTANCE="$(query "SELECT '[1,2]'::vector <-> '[2,2]'::vector")"
echo "Vector distance: $VECTOR_DISTANCE"
[ "$VECTOR_DISTANCE" = '1' ] || fail 'Unexpected vector distance'

echo "Smoke test passed."
