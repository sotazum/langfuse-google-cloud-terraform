#!/bin/bash

# Load environment variables
[ -f ../../.env ] && source ../../.env

# Check if CLICKHOUSE_URL is configured
if [ -z "${CLICKHOUSE_URL}" ]; then
  echo "Info: CLICKHOUSE_URL not configured, skipping migration."
  exit 0
fi

# Ensure CLICKHOUSE_DB is set
if [ -z "${CLICKHOUSE_DB}" ]; then
    export CLICKHOUSE_DB="default"
fi

# Ensure CLICKHOUSE_CLUSTER_NAME is set
if [ -z "${CLICKHOUSE_CLUSTER_NAME}" ]; then
    export CLICKHOUSE_CLUSTER_NAME="default"
fi

# Build HTTP URL for Clickhouse connection
HTTP_URL="${CLICKHOUSE_URL}?database=${CLICKHOUSE_DB}&user=${CLICKHOUSE_USER}&password=${CLICKHOUSE_PASSWORD}"
if [ "$CLICKHOUSE_MIGRATION_SSL" = true ] ; then
  HTTP_URL="${HTTP_URL}&secure=true&skip_verify=true"
fi

# Select migrations directory based on clustering
if [ "$CLICKHOUSE_CLUSTER_ENABLED" == "false" ] ; then
  MIGRATION_DIR="clickhouse/migrations/unclustered"
else
  MIGRATION_DIR="clickhouse/migrations/clustered"
fi

# Execute each migration file via HTTP
for sqlFile in $(ls "$MIGRATION_DIR"/*.up.sql | sort); do
  echo "Executing migration: $sqlFile"
  sql=$(cat "$sqlFile")
  echo "$sql" | gzip -c | curl -sS -X POST --data-binary @- -H 'Content-Encoding: gzip' "$HTTP_URL"
  status=$?
  if [ $status -ne 0 ]; then
    echo "Error executing migration: $sqlFile"
  else
    echo "Migration executed: $sqlFile"
  fi
done
