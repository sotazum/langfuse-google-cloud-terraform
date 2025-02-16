ALTER TABLE traces ON CLUSTER default ADD INDEX IF NOT EXISTS idx_session_id session_id TYPE bloom_filter() GRANULARITY 1;
