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

-- 2. Dry run and a billing cap (run these in Cloud Shell, not the console):
--    bq query --use_legacy_sql=false --dry_run '<your query>'
--    bq query --use_legacy_sql=false --maximum_bytes_billed=1000000000 '<your query>'
--    Record: what does the dry run report, and what happens when the cap is exceeded?

-- 3. Questions to answer out loud:
--    - Does LIMIT reduce the bytes billed on a SELECT? Why not?
--    - Why is SELECT * on a columnar store expensive?
--    - On-demand vs capacity (slot) pricing: when does each make sense?
--    - How do partition pruning and clustering reduce cost differently?
