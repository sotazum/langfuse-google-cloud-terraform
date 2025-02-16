FROM langfuse/langfuse:3

USER root
RUN apk update && apk add --no-cache curl gzip

WORKDIR /app

RUN rm -rf ./packages/shared/clickhouse/migrations/clustered/*
RUN rm -rf ./packages/shared/clickhouse/migrations/unclustered/*
COPY migrations/clustered/ ./packages/shared/clickhouse/migrations/clustered/
COPY migrations/unclustered/ ./packages/shared/clickhouse/migrations/unclustered/

COPY scripts/down.sh ./packages/shared/clickhouse/scripts/down.sh
COPY scripts/up.sh ./packages/shared/clickhouse/scripts/up.sh
COPY scripts/drop.sh ./packages/shared/clickhouse/scripts/drop.sh
