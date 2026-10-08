-- EXECUTION PLAN EXERCISE
-- How to read it: run the query in the BigQuery console, open the "Execution details" tab,
-- and switch to the execution graph. Record: slowest stage, bytes read, bytes shuffled,
-- slot time, and whether any stage shows a big gap between average and maximum time (skew).

-- Version 1: join first, filter and aggregate afterward (the naive way).
SELECT u.country, p.category, SUM(oi.sale_price) AS revenue
FROM `de-practice-lab-511020.silver.order_items` oi
JOIN `de-practice-lab-511020.silver.orders`   o ON oi.order_id   = o.order_id
JOIN `de-practice-lab-511020.silver.users`    u ON o.user_id     = u.id
JOIN `de-practice-lab-511020.silver.products` p ON oi.product_id = p.id
WHERE oi.created_at >= TIMESTAMP('2019-01-01')
  AND o.status = 'Complete'                              -- TODO: confirm status value
GROUP BY u.country, p.category;

-- Record for version 1:
--   bytes processed: ?     slot time: ?     slowest stage: ?     shuffle: ?     skew seen: ?

-- Version 2: TODO. Rewrite so each large table is filtered and reduced BEFORE the joins:
--   - select only the columns you need,
--   - pre-aggregate order_items to one row per (order_id, product category) or similar,
--   - join the small tables (products, users) last.
-- Record the same numbers for version 2 and write one sentence on what changed and why.

-- Questions to answer out loud:
--   1. Why does BigQuery shuffle data for a join, and what makes a shuffle expensive?
--   2. What is a broadcast join and when does the optimizer pick it?
--   3. What does "skew" look like in the graph and how would you fix it?
--   4. Does the order you write the joins in matter in BigQuery? Why or why not?
