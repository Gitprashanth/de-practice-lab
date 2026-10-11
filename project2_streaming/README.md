# Project 2: Streaming ingestion with Pub/Sub and Apache Beam

Start with the simplest streaming path (Pub/Sub into BigQuery), then add Beam for windowing, validation and a dead-letter path.

## Checklist

- [x] Create a topic, a BigQuery table, and a BigQuery subscription (writes messages straight into the table), with the metadata option on.
- [x] Write `publisher.py` that sends JSON order events, including one deliberate duplicate (same `event_id`) and one malformed message.
- [x] Confirm which messages reached the table; explain why the malformed one did not.
- [x] Dedupe on `event_id` in the silver layer (Pub/Sub delivers at least once).
- [x] Write `beam_pipeline.py`: parse JSON, validate, dead-letter output for invalid records, one-minute fixed windows, count and sum per window. (Prints results; writing them to BigQuery is not done.)
- [x] Run locally on a small sample file (`sample_events.jsonl`).
- [ ] Optional: run once on Dataflow, then delete the job.
- [ ] Add architecture diagram.
## Concepts to be able to explain

- Event time vs processing time; watermarks; late data; triggers
- At-least-once delivery and idempotent sinks
- Batch vs streaming trade-offs: latency, cost, complexity, correctness
- When a BigQuery subscription is enough and Dataflow is not needed

## Write-up (fill in as I build)

## Write-up

**Problem:** Practice ingesting a stream of order events on GCP: first the simplest path (Pub/Sub straight into BigQuery), then Beam for validation, dead-letter handling and windowing. Sandbox project with synthetic events, not production.

**Architecture:**
- `publisher.py` sends JSON events to the Pub/Sub topic `order-events`.
- A BigQuery subscription (table schema + write metadata) writes each message into `streaming.raw_order_events`.
- `streaming.silver_order_events` is a view that dedupes by `event_id`.
- Separately, a Beam pipeline (run locally on a sample file) parses and validates events, sends bad ones to a dead-letter output, stamps event time, and counts and sums per one-minute window.

**Key decisions and why:**
- BigQuery subscription first: no code needed when messages need no processing. Beam/Dataflow is the choice when I need validation, windowing or aggregation across messages.
- Dedupe on `event_id`, not `message_id`. Pub/Sub gives every publish a new `message_id`, and the subscription is at-least-once, so duplicates only share the producer's `event_id`.
- Silver as a view: always current, fine at this size. At scale I would use a table refreshed by a scheduled query or MERGE.
- Pub/Sub's service account got BigQuery Data Editor on this one table only (least privilege).
- Dead-letter output in Beam carries the raw record and the reason, so bad records do not block good ones.
- Windows use event time, not arrival time, so a late-arriving event still counts in the minute it happened.
- Beam run locally first: fast, free and easy to debug; Dataflow runs the same code.

**What I saw:**
- 7 messages published: 6 new rows in the table (5 valid + the duplicate), the malformed one missing. The duplicate appeared as two rows with different `message_id`s. The silver view returned one row per event.
- The malformed message is not valid JSON, so it could not be written. It was not acknowledged and stays in the subscription backlog being retried (no dead-letter topic configured).
- Beam sample run: 9 lines, 7 good, 2 dead-lettered (`invalid_json`, `missing_fields: ['order_id']`). Window counts matched my hand calculation, including an out-of-order event landing in the minute it happened.

**What went wrong and how I fixed it:**
- Running `publisher.py` from my laptop's editor sent nothing. I switched to Cloud Shell, which is already signed in to the project.
- In Cloud Shell the Pub/Sub library was missing (ImportError). I installed `google-cloud-pubsub` in a virtual environment.

**Trade-offs and what I would change in production:**
- Add a dead-letter topic on the subscription and alert on unacknowledged messages.
- Partition the raw table by `publish_time`; make silver a real table.
- Read from Pub/Sub in the Beam pipeline, write window results to BigQuery, and set allowed lateness plus a late-firing trigger.
- So far the Beam pipeline has only run locally on a sample file.
