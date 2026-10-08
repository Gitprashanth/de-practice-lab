-- GOLD: business-ready tables. Revenue comes from order_items.sale_price (orders has no amount).
-- Check the status values you found in 02_silver.sql and adjust the filter below.

CREATE OR REPLACE TABLE `de-practice-lab-511020.gold.daily_revenue`
PARTITION BY order_date
CLUSTER BY category
AS
SELECT
  DATE(oi.created_at)               AS order_date,
  p.category                        AS category,
  COUNT(DISTINCT oi.order_id)       AS orders,
  COUNT(*)                          AS items_sold,
  SUM(oi.sale_price)                AS revenue,
  SUM(oi.sale_price - p.cost)       AS gross_margin
FROM `de-practice-lab-511020.silver.order_items` oi
JOIN `de-practice-lab-511020.silver.products` p ON oi.product_id = p.id
WHERE oi.created_at >= TIMESTAMP('2019-01-01')          -- partition filter (required on this table)
  AND oi.status NOT IN ('Cancelled', 'Returned')         -- TODO: confirm exact status values
GROUP BY order_date, category;

-- TODO 1: build gold.top_products_by_category with a window function:
--         RANK() the products by revenue within each category, keep the top 5.
-- TODO 2: create a MATERIALIZED VIEW over a simple aggregate (for example monthly revenue
--         from gold.daily_revenue). Materialized views have restrictions on what SQL they allow;
--         note what happens if you try a window function or a non-deterministic function.
-- TODO 3: write one line each: when would you use a materialized view, a scheduled query,
--         or a dbt model instead?
