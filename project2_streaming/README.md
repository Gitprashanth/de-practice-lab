# Project 2: Streaming ingestion with Pub/Sub and Apache Beam

Start with the simplest streaming path (Pub/Sub into BigQuery), then add Beam for windowing, validation and a dead-letter path.

## Checklist

- [ ] Create a topic, a BigQuery table, and a BigQuery subscription (writes messages straight into the table). Enable the metadata option for message_id and publish_time.
- [ ] Write `publisher.py` that sends JSON order events, including one deliberate duplicate (same `event_id`) and one malformed message.
- [ ] Confirm which messages reached the table; explain why the malformed one did not.
- [ ] Dedupe on `event_id` in the silver layer (Pub/Sub delivers at least once).
- [ ] Write `beam_pipeline.py`: parse JSON, validate, send invalid records to a dead-letter output, one-minute fixed windows, aggregate per window, write to BigQuery.
- [ ] Run locally with the DirectRunner.
- [ ] Optional: run once on Dataflow, then delete the job.
- [ ] Add architecture diagram.

## Concepts to be able to explain

- Event time vs processing time; watermarks; late data; triggers
- At-least-once delivery and idempotent sinks
- Batch vs streaming trade-offs: latency, cost, complexity, correctness
- When a BigQuery subscription is enough and Dataflow is not needed

## Write-up (fill in as I build)

**Problem:**

**Architecture:**

**Key decisions and why:**

**What went wrong and how I fixed it:**

**Trade-offs and what I would change in production:**
