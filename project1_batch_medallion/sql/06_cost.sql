-- COST CONTROL

-- 1. Top 10 jobs by bytes billed in the last 7 days (region qualifier must match dataset location).
SELECT
  creation_time, user_email, job_id,
  total_bytes_billed / POW(1024, 3) AS gib_billed,
  total_slot_ms / 1000              AS slot_seconds,
  LEFT(query, 120)                  AS query_start
FROM `region-us`.INFORMATION_SCHEMA.JOBS_BY_PROJECT
WHERE creation_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
  AND job_type = 'QUERY'
ORDER BY total_bytes_billed DESC
LIMIT 10;

-- 2. Dry run, billing cap, partition filter (run in Cloud Shell, not the console):
--    bq query --use_legacy_sql=false --dry_run '<your query>'
--    bq query --use_legacy_sql=false --maximum_bytes_billed=1000000 '<your query>'
--
-- Results from my runs:
--   Dry run (COUNT(*) on silver.order_items with a created_at filter):
--     "upper bound of 1449296 bytes" (~1.4 MB). Nothing scanned, nothing charged.
--     It is an upper bound, not an exact number.
--   Billing cap of 1,000,000 bytes on the same query:
--     "Query exceeded limit for bytes billed: 1000000. 10485760 or higher required."
--     BigQuery bills a 10 MB minimum per table, so the cap must be at least that.
--     A query refused by the cap is not charged.
--   Query with no date filter on silver.order_items (require_partition_filter = TRUE):
--     "Cannot query over table ... without a filter over column(s) 'created_at'
--      that can be used for partition elimination." Enforced for every user and tool.
--
-- What I saw in INFORMATION_SCHEMA.JOBS (last 7 days):
--   Biggest job by bytes billed: 0.078 GiB. Many jobs billed exactly 0.039 GiB (40 MB =
--   4 tables x the 10 MB minimum). Version 1 and Version 2 of the join billed the same
--   bytes but used 1,163 vs 1,959 slot-seconds.
--   Sort by bytes billed for on-demand cost; sort by slot-seconds for speed/capacity.

-- 3. Questions answered:
--  - Does LIMIT reduce bytes billed? Not on a non-clustered table. On a clustered table it
--    can, because scanning can stop early, but I do not rely on it. My dry run showed
--    17,038,494 bytes with and without LIMIT 10, but a dry run is only an upper bound.
--    To cut cost: select fewer columns and filter on the partition column.
--  - Why is SELECT * expensive on a columnar store? Columns are stored separately, so
--    BigQuery reads only the columns you name. SELECT * read ~17 MB, COUNT(*) ~1.4 MB.
--  - On-demand vs capacity: on-demand charges per TiB scanned, good for light or
--    unpredictable use. Capacity charges for slots (compute) per hour, good for heavy
--    steady workloads that need a predictable bill.
--  - Partition pruning vs clustering: partitioning skips whole date segments and the cost
--    is known before the query runs. Clustering sorts data inside them (best on
--    high-cardinality filter columns) and skips blocks, but the exact cost is only
--    known after the query runs.