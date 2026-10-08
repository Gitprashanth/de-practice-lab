-- BRONZE: raw copy, no cleaning. Add load metadata so every row is traceable.
-- order_items is the biggest table, so it gets partitioning + clustering here.

CREATE OR REPLACE TABLE `de-practice-lab-511020.bronze.orders` AS
SELECT *, CURRENT_TIMESTAMP() AS _loaded_at, 'batch_001' AS _batch_id
FROM `bigquery-public-data.thelook_ecommerce.orders`;

CREATE OR REPLACE TABLE `de-practice-lab-511020.bronze.order_items`
PARTITION BY DATE(created_at)
CLUSTER BY user_id
AS
SELECT *, CURRENT_TIMESTAMP() AS _loaded_at, 'batch_001' AS _batch_id
FROM `bigquery-public-data.thelook_ecommerce.order_items`;

CREATE OR REPLACE TABLE `de-practice-lab-511020.bronze.products` AS
SELECT *, CURRENT_TIMESTAMP() AS _loaded_at, 'batch_001' AS _batch_id
FROM `bigquery-public-data.thelook_ecommerce.products`;

CREATE OR REPLACE TABLE `de-practice-lab-511020.bronze.users` AS
SELECT *, CURRENT_TIMESTAMP() AS _loaded_at, 'batch_001' AS _batch_id
FROM `bigquery-public-data.thelook_ecommerce.users`;

-- Sanity check: row counts should match the source.
-- TODO: write a query that compares COUNT(*) of each bronze table with its source table.
