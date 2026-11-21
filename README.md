# DE Practice Lab

Small, hands-on projects built in a personal Google Cloud sandbox to practice batch, streaming and governed-data patterns on GCP. Each project has its own README with the problem, architecture, decisions and trade-offs.

These are learning projects on public or synthetic data, not production systems.

## Projects

| # | Project | What it covers | Status |
| --- | --- | --- | --- |
| 1 | [Batch medallion pipeline](project1_batch_medallion/) | BigQuery SQL: bronze, silver, gold, MERGE, query plans, cost | Done |
| 2 | [Streaming ingestion](project2_streaming/) | Pub/Sub, BigQuery subscription, Beam, Dataflow | Done. The Dataflow run was a batch job over a file, not a streaming job |
| 3 | [dbt, Airflow and governed data](project3_dbt_airflow_dataplex/) | dbt models and tests, Airflow DAG, lineage, data quality scan | Built. The DAG is written but not run on a live server |
| 4 | Spark and BigLake | PySpark, BigLake tables | Planned, not started |

Each project has its own README with the problem, design decisions and trade-offs.

## Dataset

`bigquery-public-data.thelook_ecommerce` (synthetic e-commerce data). Confirm table names in the BigQuery console before running anything.

## Environment

- Google Cloud project: `de-practice-lab` (free trial)
- Work done in Cloud Shell (Python 3.12, gcloud, Docker preinstalled)
- Bucket region: `us-central1`

## Clean-up checklist

After each project, delete Dataflow jobs, Dataproc clusters or batches, and Pub/Sub subscriptions you no longer need.
