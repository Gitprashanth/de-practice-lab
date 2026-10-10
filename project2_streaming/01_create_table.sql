-- Landing table for the BigQuery subscription (use table schema + write metadata).
-- The last four columns are filled in by Pub/Sub, so their names and types must match exactly.
CREATE SCHEMA IF NOT EXISTS `de-practice-lab-511020.streaming` OPTIONS (location = 'US');

CREATE TABLE `de-practice-lab-511020.streaming.raw_order_events` (
  event_id          STRING,
  order_id          INT64,
  user_id           INT64,
  status            STRING,
  amount            FLOAT64,
  event_time        TIMESTAMP,
  subscription_name STRING,
  message_id        STRING,
  publish_time      TIMESTAMP,
  attributes        STRING
);