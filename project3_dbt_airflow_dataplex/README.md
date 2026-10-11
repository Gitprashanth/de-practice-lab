# Project 3: dbt, Airflow and governed data

Turn Project 1 into an orchestrated, tested and traceable pipeline.

## Checklist

- [*] dbt (in a virtual environment: `pip install dbt-bigquery`): staging models over silver; one incremental mart (daily revenue) partitioned by date.
- [*] Tests: `unique`, `not_null`, `relationships`, `accepted_values`. Run `dbt build`; generate docs.
- [*] Airflow DAG (`dags/lab_pipeline.py`): load, MERGE, quality checks, dbt run. Retries with backoff, failure alerting, idempotent date-parameterized SQL, task dependencies.
- [ ] Validate the DAG locally with `airflow dags test`.
- [*] Dataplex: enable the Data Lineage API; run the Project 1 and 3 jobs; view the table's Lineage tab. Note whether column-level lineage appears.
- [*] Dataplex data quality scan on the silver table: built-in rules plus one custom SQL rule; run it and read the results.
- [ ] Add architecture diagram showing quality gates.

## AI-ready data: five pillars, mapped to what I built

| Pillar | What I built |
| --- | --- |
| Quality | dbt tests, Dataplex scan |
| Governance | IAM and policy tags (conceptual) |
| Lineage | Dataplex lineage |
| Consistency | Medallion layers, dbt models |
| Freshness | Airflow schedule and alerts |

## Write-up

**Problem:** Turn the Project 1 batch pipeline (bronze, silver, gold) into something orchestrated, tested and traceable, on public synthetic data.

**Architecture:** Airflow DAG (written, not run on a live server): quality check on silver.orders, then MERGE of a new batch into silver.orders, then `dbt build`. dbt: 4 staging views over silver, one incremental mart (`daily_revenue`, partitioned by order_date, clustered by category). Knowledge Catalog (formerly Dataplex): lineage and a data quality scan on silver.orders.

**Key decisions and why:**
- `dbt build` instead of `dbt run`, so a failing test stops the models downstream of it.
- `daily_revenue` is incremental with `insert_overwrite`: it replaces whole day-partitions, and recalculates the last 3 days to catch late rows.
- The MERGE in the DAG uses `{{ ds }}` instead of `CURRENT_TIMESTAMP()`, so re-running a date uses the same window (idempotent).
- `silver.order_items` requires a partition filter, so the staging model carries a date floor (`earliest_date` variable, 2019-01-01). The dbt view built fine, but the first query failed, which is how BigQuery applies that rule to views.

**What I saw in lineage and quality results:**
- dbt: 5 models and 16 tests, 21 steps, all passed. A test I wrote to fail on purpose (no Returned orders) failed with 12,512 rows. 12,421 were from batch_001 (the original source) and 91 from batch_002, so the rule was wrong, not the data.
- Incremental run: first run 42.6k rows, 7.9 MiB, 35 s. Second run about 1 MiB, 14 s.
- Lineage: column-level lineage appeared on the Project 1 gold table (order_items and products into daily_revenue into monthly_revenue_mv). The dbt-built table showed nothing yet; Google documents a delay of 30 minutes to 24 hours.
- Data quality scan on silver.orders: uniqueness and null check on order_id passed. The status value-set rule failed at first because of a typo in my own list, then passed. The rule "returned_at IS NULL OR delivered_at IS NOT NULL" fails on 62 rows, all from batch_002. The cause is my simulation, which sets Returned without a delivery date.

**Trade-offs and what I would change in production:**
- The 3-day lookback leaves old days stale if an order changes status later; use a longer lookback or a periodic full refresh.
- The date floor in staging silently hides older data.
- dbt would run in its own container, not in a BashOperator on Airflow workers.
- The DAG should be tested on a real Airflow or Composer environment.
- Fix the MERGE simulation so Returned rows also carry a delivery date, then re-run the scan.

**Problem:**

**Architecture:**

**Key decisions and why:**

**What I saw in lineage and quality results:**

**Trade-offs and what I would change in production:**
