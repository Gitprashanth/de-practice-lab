"""Lab pipeline: quality gate on silver, MERGE a new batch into silver.orders, then dbt build.
Written for Airflow 3 (airflow.sdk). Written and reviewed, not run on a live Airflow server."""
from datetime import datetime, timedelta

from airflow.providers.google.cloud.operators.bigquery import (
    BigQueryCheckOperator,
    BigQueryInsertJobOperator,
)
from airflow.providers.standard.operators.bash import BashOperator
from airflow.sdk import DAG

PROJECT = "de-practice-lab-511020"
LOCATION = "US"
DBT_DIR = "~/de-practice-lab/project3_dbt_airflow_dataplex/lab_dbt"


def alert_on_failure(context):
    """Runs when a task fails after all retries. In production this would post to Slack or email."""
    ti = context["task_instance"]
    print(f"ALERT: task {ti.task_id} in DAG {ti.dag_id} failed (run {ti.run_id}).")


default_args = {
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
    "retry_exponential_backoff": True,
    "max_retry_delay": timedelta(minutes=30),
    "on_failure_callback": alert_on_failure,
}

# The ON clause only looks at the last 90 days of the target, so the MERGE prunes partitions.
# {{ ds }} is the run's logical date, so re-running a past date uses the same window.
MERGE_SQL = """
MERGE `de-practice-lab-511020.silver.orders` T
USING (
  SELECT * FROM `de-practice-lab-511020.silver.orders_batch_002`
  QUALIFY ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY _loaded_at DESC) = 1
) S
ON T.order_id = S.order_id
   AND T.created_at >= TIMESTAMP_SUB(TIMESTAMP('{{ ds }}'), INTERVAL 90 DAY)
WHEN MATCHED AND T.status != S.status THEN UPDATE SET
  status = S.status,
  shipped_at = S.shipped_at,
  delivered_at = S.delivered_at,
  returned_at = S.returned_at,
  num_of_item = S.num_of_item,
  _loaded_at = S._loaded_at,
  _batch_id = S._batch_id
WHEN NOT MATCHED THEN
  INSERT (order_id, user_id, status, created_at, shipped_at, delivered_at,
          returned_at, num_of_item, _loaded_at, _batch_id)
  VALUES (S.order_id, S.user_id, S.status, S.created_at, S.shipped_at, S.delivered_at,
          S.returned_at, S.num_of_item, S._loaded_at, S._batch_id)
"""

with DAG(
    dag_id="lab_pipeline",
    start_date=datetime(2026, 10, 1),
    schedule="0 6 * * *",
    catchup=False,
    default_args=default_args,
    tags=["lab"],
):
    # Gate 1: silver must have rows and no NULL keys, or nothing downstream runs.
    check_silver = BigQueryCheckOperator(
        task_id="check_silver_orders",
        sql=f"SELECT COUNT(*) > 0 AND COUNTIF(order_id IS NULL) = 0 FROM `{PROJECT}.silver.orders`",
        use_legacy_sql=False,
        location=LOCATION,
    )

    merge_orders = BigQueryInsertJobOperator(
        task_id="merge_orders",
        configuration={"query": {"query": MERGE_SQL, "useLegacySql": False}},
        location=LOCATION,
    )

    # Gate 2: dbt build runs the models and their tests; a failing test stops the downstream models.
    dbt_build = BashOperator(
        task_id="dbt_build",
        bash_command=f"cd {DBT_DIR} && dbt build",
    )

    check_silver >> merge_orders >> dbt_build