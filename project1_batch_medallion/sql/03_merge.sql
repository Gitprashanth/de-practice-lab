-- MERGE: apply a second batch (new rows + changed rows + duplicates) to silver.orders.
-- Run the simulation first, then write the MERGE yourself.

-- Step A: simulate batch_002.
-- 100 existing recent orders flip to 'Returned', one brand-new order is added,
-- and one of the changed rows is repeated to create a duplicate in the batch.
CREATE OR REPLACE TABLE `de-practice-lab-511020.silver.orders_batch_002` AS
WITH changed AS (
  SELECT * REPLACE ('Returned' AS status, CURRENT_TIMESTAMP() AS returned_at,
                    CURRENT_TIMESTAMP() AS _loaded_at, 'batch_002' AS _batch_id)
  FROM `de-practice-lab-511020.silver.orders`
  WHERE created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 60 DAY)
  LIMIT 100
),
new_row AS (
  SELECT 999999001 AS order_id, 1 AS user_id, 'Processing' AS status,
         CURRENT_TIMESTAMP() AS created_at, CAST(NULL AS TIMESTAMP) AS shipped_at,
         CAST(NULL AS TIMESTAMP) AS delivered_at, CAST(NULL AS TIMESTAMP) AS returned_at,
         1 AS num_of_item, CURRENT_TIMESTAMP() AS _loaded_at, 'batch_002' AS _batch_id
)
SELECT * FROM changed
UNION ALL SELECT * FROM new_row
UNION ALL SELECT * FROM (SELECT * FROM changed LIMIT 1);

-- Step B: your turn.
-- TODO 1: dedupe the batch first (a MERGE fails if two source rows match one target row).
-- TODO 2: MERGE into silver.orders ON order_id. Update when matched, insert when not matched.
-- TODO 3: only update when something actually changed (status differs), so unchanged rows
--         are not rewritten.
-- TODO 4: make the MERGE prune partitions. Add a predicate on the partition column to the ON
--         clause, and be ready to explain what you gave up by doing that.
--
-- MERGE `de-practice-lab-511020.silver.orders` T
-- USING ( ...deduped batch... ) S
-- ON ...
-- WHEN MATCHED AND ... THEN UPDATE SET ...
-- WHEN NOT MATCHED THEN INSERT ROW;

-- Step C: verify. Order 999999001 should exist; the 100 changed orders should be 'Returned';
-- total row count should be previous count + 1.
