# Project 1: Batch medallion pipeline on BigQuery

Build bronze, silver and gold layers from `bigquery-public-data.thelook_ecommerce`, then tune queries using the execution plan.

## How to run

In Cloud Shell, clone the repo (it is public, so no login is needed):

```bash
git clone https://github.com/Gitprashanth/de-practice-lab.git
cd de-practice-lab/project1_batch_medallion
bq query --use_legacy_sql=false < sql/00_setup.sql
bq query --use_legacy_sql=false < sql/01_bronze.sql
```

Or paste each file into the BigQuery console query editor. Files marked TODO are for me to finish.

## Checklist

- [ ] Setup: create the `bronze`, `silver`, `gold` datasets in the US location. (`sql/00_setup.sql`)
- [ ] Bronze: copy `orders`, `order_items`, `users`, `products` into my dataset with `_loaded_at` and `_batch_id` columns. Partition `order_items` by date, cluster by `user_id`. (`sql/01_bronze.sql`)
- [ ] Silver: deduplicate with `ROW_NUMBER()` on the business key, latest `_loaded_at` wins. (`sql/02_silver.sql`)
- [ ] Simulate a second batch with changed and duplicate rows; load with `MERGE`. (`sql/03_merge.sql`)
- [ ] Set `require_partition_filter` on the large table and confirm an unfiltered query is rejected.
- [ ] Gold: daily revenue by category table plus a materialized view. (`sql/04_gold.sql`)
- [ ] Execution plan: run a three-table join, record the slowest stage, bytes read and skew; rewrite to filter and pre-aggregate before the join; compare. (`sql/05_explain.sql`)
- [ ] Cost: query `INFORMATION_SCHEMA.JOBS` for top jobs by bytes billed; try dry run and `maximum_bytes_billed`. (`sql/06_cost.sql`)
- [ ] Add architecture diagram and screenshots to `images/`.

## Write-up (fill in as I build)

## Write-up

**Problem:** Practice a batch pipeline on BigQuery with public e-commerce data (thelook_ecommerce): keep the raw data, clean it, build business-ready tables, and tune queries and cost. This is a sandbox project, not production.

**Architecture:** Bronze, silver, gold.
- Bronze: raw copy of orders, order_items, products and users, plus `_loaded_at` and `_batch_id`. order_items is partitioned by date and clustered by user_id.
- Silver: deduplicated with `ROW_NUMBER()` (latest load wins), bad rows filtered, personal fields dropped from users. `require_partition_filter` is on order_items.
- Gold: `daily_revenue`, `top_products_by_category` (RANK), and a materialized view `monthly_revenue_mv`.
- A simulated second batch is applied to silver.orders with MERGE.

**Key decisions and why:**
- Raw copy in bronze, so I can reprocess without going back to the source.
- `_batch_id` makes reruns safe and traceable.
- MERGE matches on `order_id` only. Comparing `created_at` between target and source would have inserted duplicates silently.
- MERGE updates only when status differs, and has a 90-day partition window. The trade-off: rows older than the window can no longer be updated.
- After the load, the source changed. Time travel showed bronze matched the source exactly at load time, so it was source drift, not a load defect.
- Materialized view for a simple aggregate; scheduled query when SQL is too complex for one.

**What I saw in the execution plan (before / after, with numbers):**
- Version 1 (join first): 10.93 MB processed, 1,163 slot-seconds, 4.69 MB shuffled. The slowest stage was the join, and the S02 read showed skew (max 1.37 s vs avg 48 ms).
- Version 2 (pre-aggregate first): same bytes, 1,959 slot-seconds, 18.12 MB shuffled, same 309 rows. It was worse.
- The plan showed BigQuery already broadcast the small tables, and my pre-aggregation merged only 4 rows and added a shuffle.

**Trade-offs and what I would change in production:**
- Batch 2 is simulated from silver; in production it would land in bronze first.
- Bad rows are not quarantined yet.
- My tables are too small to show real partition and clustering gains.
- Cost controls tested: dry run, `maximum_bytes_billed`, `require_partition_filter`.
