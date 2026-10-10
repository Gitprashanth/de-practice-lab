-- Pub/Sub delivers at least once, and every publish gets a new message_id.
-- So duplicates are found by event_id (set by the producer), and the earliest arrival wins.
CREATE OR REPLACE VIEW `de-practice-lab-511020.streaming.silver_order_events` AS
SELECT event_id, order_id, user_id, status, amount, event_time, message_id, publish_time
FROM `de-practice-lab-511020.streaming.raw_order_events`
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY event_id ORDER BY publish_time ASC, message_id
) = 1;