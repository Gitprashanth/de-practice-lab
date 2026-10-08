# Project 3: dbt, Airflow and governed data

Turn Project 1 into an orchestrated, tested and traceable pipeline.

## Checklist

- [ ] dbt (in a virtual environment: `pip install dbt-bigquery`): staging models over silver; one incremental mart (daily revenue) partitioned by date.
- [ ] Tests: `unique`, `not_null`, `relationships`, `accepted_values`. Run `dbt build`; generate docs.
- [ ] Airflow DAG (`dags/lab_pipeline.py`): load, MERGE, quality checks, dbt run. Retries with backoff, failure alerting, idempotent date-parameterized SQL, task dependencies.
- [ ] Validate the DAG locally with `airflow dags test`.
- [ ] Dataplex: enable the Data Lineage API; run the Project 1 and 3 jobs; view the table's Lineage tab. Note whether column-level lineage appears.
- [ ] Dataplex data quality scan on the silver table: built-in rules plus one custom SQL rule; run it and read the results.
- [ ] Add architecture diagram showing quality gates.

## AI-ready data: five pillars, mapped to what I built

| Pillar | What I built |
| --- | --- |
| Quality | dbt tests, Dataplex scan |
| Governance | IAM and policy tags (conceptual) |
| Lineage | Dataplex lineage |
| Consistency | Medallion layers, dbt models |
| Freshness | Airflow schedule and alerts |

## Write-up (fill in as I build)

**Problem:**

**Architecture:**

**Key decisions and why:**

**What I saw in lineage and quality results:**

**Trade-offs and what I would change in production:**
