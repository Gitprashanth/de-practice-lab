# Project 4: Spark and BigLake

## Checklist

- [ ] PySpark (`pip install pyspark`, run locally in Cloud Shell): read order data as Parquet from Cloud Storage; join, aggregate, window function (rank); write Parquet partitioned by date. (`spark_job.py`)
- [ ] Optional: submit the same script once as a Dataproc job; delete the cluster or batch afterward. Check current Dataproc docs for the exact command.
- [ ] Create the bucket in `us-central1` (inside the Cloud Storage free tier regions).
- [ ] Create a BigQuery external or BigLake table over the Parquet files; query it; compare with a native table (speed, cost, governance).
- [ ] Fill in the which-database-when table below.
- [ ] Practice the migration framework out loud (90 seconds).

## Which database when

| Service | Type | Pick it when |
| --- | --- | --- |
| BigQuery | Analytical columnar warehouse | |
| Bigtable | Wide-column NoSQL | |
| Spanner | Relational, horizontally scalable | |
| Cloud SQL | Managed MySQL, PostgreSQL, SQL Server | |
| Firestore | Serverless document database | |
| MongoDB | Document database | |

## Migration framework

Assess, prioritize, choose a pattern per workload (lift-and-shift or refactor), move the data, validate with reconciliation, cut over with a rollback plan.

## Write-up (fill in as I build)

**Problem:**

**Key decisions and why:**

**Native vs BigLake table comparison:**

**Trade-offs:**
