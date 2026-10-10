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
CREATE OR REPLACE TABLE `de-practice-lab-511020.gold.top_products_by_category` AS
SELECT
  p.category,
  oi.product_id,
  p.name AS product_name,
  SUM(oi.sale_price) AS revenue,
  RANK() OVER (PARTITION BY p.category ORDER BY SUM(oi.sale_price) DESC) AS rk
FROM `de-practice-lab-511020.silver.order_items` oi
JOIN `de-practice-lab-511020.silver.products` p ON oi.product_id = p.id
WHERE oi.created_at >= TIMESTAMP('2019-01-01')
  AND oi.status NOT IN ('Cancelled', 'Returned')
GROUP BY 1, 2, 3
QUALIFY rk <= 5;

-- TODO 2: create a MATERIALIZED VIEW over a simple aggregate (for example monthly revenue
--         from gold.daily_revenue). Materialized views have restrictions on what SQL they allow;
--         note what happens if you try a window function or a non-deterministic function.

CREATE MATERIALIZED VIEW `de-practice-lab-511020.gold.monthly_revenue_mv` AS
SELECT DATE_TRUNC(order_date, MONTH) AS month,
       category,
       SUM(revenue) AS revenue,
       SUM(items_sold) AS items_sold
FROM `de-practice-lab-511020.gold.daily_revenue`
GROUP BY 1, 2;

-- TODO 3: write one line each: when would you use a materialized view, a scheduled query,
--         or a dbt model instead?
-- Materialized view: a simple sum, count or group-by that many people query again and again, such as a dashboard. 
-- BigQuery keeps it fresh.

-- Scheduled query: any SQL that runs at a set time and writes a table, including complex SQL (window functions, joins)
-- that a materialized view rejects. You own the schedule.

-- dbt model: SQL kept in version control, with tests, documentation, and dependencies between models.
-- Use it when many tables depend on each other and need testing and review. We’ll build this in Project 3.