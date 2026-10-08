# Project 1: Batch medallion pipeline on BigQuery

Build bronze, silver and gold layers from `bigquery-public-data.thelook_ecommerce`, then tune queries using the execution plan.

## How to run

In Cloud Shell, after cloning the repo (it is public, so no login is needed):

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

**Problem:**

**Architecture:**

**Key decisions and why:**

**What I saw in the execution plan (before / after, with numbers):**

**Trade-offs and what I would change in production:**
