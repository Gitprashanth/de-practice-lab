-- SILVER: deduplicated, typed, filtered, and stripped of columns the business layer does not need.
-- Dedup rule: one row per business key, the most recently loaded row wins.

-- Before building silver, look at the data. Fill in what you find:
--   SELECT DISTINCT status FROM `de-practice-lab-511020.bronze.orders`;       -- values: ?
--   SELECT DISTINCT status FROM `de-practice-lab-511020.bronze.order_items`;  -- values: ?
--   Are there NULL created_at or NULL keys? Duplicate order_ids?                -- ?

CREATE OR REPLACE TABLE `de-practice-lab-511020.silver.orders`
PARTITION BY DATE(created_at)
CLUSTER BY user_id, status
AS
SELECT
  order_id, user_id, status, created_at, shipped_at, delivered_at, returned_at, num_of_item,
  _loaded_at, _batch_id
FROM `de-practice-lab-511020.bronze.orders`
WHERE order_id IS NOT NULL AND created_at IS NOT NULL
QUALIFY ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY _loaded_at DESC) = 1;

CREATE OR REPLACE TABLE `de-practice-lab-511020.silver.order_items`
PARTITION BY DATE(created_at)
CLUSTER BY order_id, product_id
OPTIONS (require_partition_filter = TRUE)
AS
SELECT
  id, order_id, user_id, product_id, inventory_item_id, status,
  created_at, shipped_at, delivered_at, returned_at, sale_price,
  _loaded_at, _batch_id
FROM `de-practice-lab-511020.bronze.order_items`
WHERE id IS NOT NULL AND created_at IS NOT NULL AND sale_price >= 0
QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY _loaded_at DESC) = 1;

CREATE OR REPLACE TABLE `de-practice-lab-511020.silver.products` AS
SELECT id, name, brand, category, department, cost, retail_price, sku, distribution_center_id,
       _loaded_at, _batch_id
FROM `de-practice-lab-511020.bronze.products`
WHERE id IS NOT NULL
QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY _loaded_at DESC) = 1;

-- Users: personal fields (names, email, street address, exact coordinates) are deliberately
-- NOT carried into silver. Analytics does not need them; fewer copies of personal data is safer.
CREATE OR REPLACE TABLE `de-practice-lab-511020.silver.users` AS
SELECT id, age, gender, state, city, country, traffic_source, created_at,
       _loaded_at, _batch_id
FROM `de-practice-lab-511020.bronze.users`
WHERE id IS NOT NULL
QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY _loaded_at DESC) = 1;

-- TODO: add one data-quality check query that returns the count of order_items whose order_id
--       has no matching row in silver.orders (an orphan check). Remember the partition filter.
