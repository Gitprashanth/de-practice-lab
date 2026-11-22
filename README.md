# GCP Pipeline Labs

Practice projects I built on Google Cloud to learn batch, streaming and governed-data patterns. They use sample data (BigQuery's `thelook_ecommerce`, which is synthetic). I built them with AI help. They are not production work.

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

