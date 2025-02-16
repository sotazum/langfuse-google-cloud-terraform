#!/bin/bash

# Load environment variables
source ../../.env

if [ -z "${CLICKHOUSE_URL}" ]; then
  echo "Info: CLICKHOUSE_URL not configured, skipping drop."
  exit 0
fi

# Ensure CLICKHOUSE_DB is set
if [ -z "${CLICKHOUSE_DB}" ]; then
    export CLICKHOUSE_DB="default"
fi

# Build HTTP URL for Clickhouse connection
HTTP_URL="${CLICKHOUSE_URL}?database=${CLICKHOUSE_DB}&user=${CLICKHOUSE_USER}&password=${CLICKHOUSE_PASSWORD}"
if [ "$CLICKHOUSE_MIGRATION_SSL" = true ] ; then
  HTTP_URL="${HTTP_URL}&secure=true&skip_verify=true"
fi

# Execute drop migrations from both directories, splitting multi-statement files
for dir in clickhouse/migrations/unclustered clickhouse/migrations/clustered; do
  for sqlFile in $(ls "$dir"/*.down.sql | sort -V); do
    echo "Dropping $sqlFile"
    sql=$(cat "$sqlFile")
    echo "$sql" | gzip -c | curl -sS -X POST --data-binary @- -H 'Content-Encoding: gzip' "$HTTP_URL"
    status=$?
    if [ $status -ne 0 ]; then
      echo "Error dropping migration: $sqlFile"
    else
      echo "Migration dropped: $sqlFile"
    fi
  done
done