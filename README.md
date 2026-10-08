# DE Practice Lab

Small, hands-on projects built in a personal Google Cloud sandbox to practice batch, streaming and governed-data patterns on GCP. Each project has its own README with the problem, architecture, decisions and trade-offs.

These are learning projects on public or synthetic data, not production systems.

## Projects

| # | Project | Main services | Status |
| --- | --- | --- | --- |
| 1 | [Batch medallion pipeline](project1_batch_medallion/) | BigQuery, SQL | [ ] |
| 2 | [Streaming ingestion](project2_streaming/) | Pub/Sub, BigQuery subscription, Apache Beam, Dataflow | [ ] |
| 3 | [dbt, Airflow and governed data](project3_dbt_airflow_dataplex/) | dbt, Airflow, Dataplex | [ ] |
| 4 | [Spark and BigLake](project4_spark_biglake/) | PySpark, Cloud Storage, BigLake | [ ] |

## Dataset

`bigquery-public-data.thelook_ecommerce` (synthetic e-commerce data). Confirm table names in the BigQuery console before running anything.

## Environment

- Google Cloud project: `de-practice-lab` (free trial)
- Work done in Cloud Shell (Python 3.12, gcloud, Docker preinstalled)
- Bucket region: `us-central1`

## Clean-up checklist

After each project, delete Dataflow jobs, Dataproc clusters or batches, and Pub/Sub subscriptions you no longer need.
