"""Beam pipeline: parse and validate order events, route bad records to a dead-letter output."""
import json

import apache_beam as beam
from apache_beam import pvalue

REQUIRED_FIELDS = ["event_id", "order_id", "user_id", "status", "amount", "event_time"]


class ParseAndValidate(beam.DoFn):
    DEAD_LETTER = "dead_letter"

    def process(self, line):
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            yield pvalue.TaggedOutput(self.DEAD_LETTER, {"raw": line, "reason": "invalid_json"})
            return

        if not isinstance(event, dict):
            yield pvalue.TaggedOutput(self.DEAD_LETTER, {"raw": line, "reason": "not_an_object"})
            return

        missing = [f for f in REQUIRED_FIELDS if event.get(f) is None]
        if missing:
            yield pvalue.TaggedOutput(
                self.DEAD_LETTER, {"raw": line, "reason": f"missing_fields: {missing}"}
            )
            return

        yield event  # main output: a good event


def run():
    with beam.Pipeline() as p:
        results = (
            p
            | "Read" >> beam.io.ReadFromText("sample_events.jsonl")
            | "ParseAndValidate"
            >> beam.ParDo(ParseAndValidate()).with_outputs(
                ParseAndValidate.DEAD_LETTER, main="good"
            )
        )
        results.good | "PrintGood" >> beam.Map(lambda e: print("GOOD", e["event_id"]))
        results[ParseAndValidate.DEAD_LETTER] | "PrintDead" >> beam.Map(
            lambda d: print("DEAD", d["reason"])
        )


if __name__ == "__main__":
    run()