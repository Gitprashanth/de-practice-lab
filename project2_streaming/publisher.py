"""Send test order events to the Pub/Sub topic order-events."""
import json
from datetime import datetime, timezone

from google.cloud import pubsub_v1

PROJECT_ID = "de-practice-lab-511020"
TOPIC_ID = "order-events"

publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path(PROJECT_ID, TOPIC_ID)


def make_event(event_id, order_id, status, amount):
    return {
        "event_id": event_id,
        "order_id": order_id,
        "user_id": 40 + order_id % 5,
        "status": status,
        "amount": amount,
        "event_time": datetime.now(timezone.utc).isoformat(),
    }


def publish(label, payload):
    message_id = publisher.publish(topic_path, payload).result()
    print(f"{label:<10} message_id={message_id}")


def main():
    events = [
        make_event("e-1001", 1001, "Processing", 25.00),
        make_event("e-1002", 1002, "Shipped", 40.50),
        make_event("e-1003", 1003, "Complete", 19.99),
        make_event("e-1004", 1004, "Processing", 75.25),
        make_event("e-1005", 1005, "Cancelled", 12.00),
    ]
    for event in events:
        publish("valid", json.dumps(event).encode("utf-8"))

    # Same event_id and same content as e-1003, sent a second time.
    publish("duplicate", json.dumps(events[2]).encode("utf-8"))

    # Not valid JSON at all.
    publish("malformed", b"this is not json {")


if __name__ == "__main__":
    main()