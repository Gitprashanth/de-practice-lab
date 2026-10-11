"""Beam pipeline: validate order events, route bad ones to a dead-letter output,
then count orders and sum amounts per one-minute window of EVENT time.
Runs locally by default; pass Dataflow options on the command line to run in the cloud."""
import argparse
import json
from datetime import datetime

import apache_beam as beam
from apache_beam import pvalue
from apache_beam.options.pipeline_options import PipelineOptions, SetupOptions
from apache_beam.transforms import window

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


def to_event_time(event):
    """Tell Beam when the event HAPPENED (from the event itself), not when it arrived."""
    ts = datetime.fromisoformat(event["event_time"].replace("Z", "+00:00")).timestamp()
    return window.TimestampedValue(event, ts)


class FormatWindow(beam.DoFn):
    def process(self, result, win=beam.DoFn.WindowParam):
        count, total = result
        start = win.start.to_utc_datetime().strftime("%H:%M")
        yield f"window {start} UTC  orders={count}  total={total:.2f}"


def run(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", default="sample_events.jsonl")
    parser.add_argument("--output", default="output/windows")
    parser.add_argument("--dead_letter_output", default="output/dead_letter")
    known_args, pipeline_args = parser.parse_known_args(argv)

    options = PipelineOptions(pipeline_args)
    options.view_as(SetupOptions).save_main_session = True  # needed on Dataflow workers

    with beam.Pipeline(options=options) as p:
        results = (
            p
            | "Read" >> beam.io.ReadFromText(known_args.input)
            | "ParseAndValidate"
            >> beam.ParDo(ParseAndValidate()).with_outputs(
                ParseAndValidate.DEAD_LETTER, main="good"
            )
        )

        (
            results.good
            | "StampEventTime" >> beam.Map(to_event_time)
            | "OneMinuteWindows" >> beam.WindowInto(window.FixedWindows(60))
            | "ToPairs" >> beam.Map(lambda e: (1, e["amount"]))
            | "CountAndSum"
            >> beam.CombineGlobally(
                lambda pairs: (sum(p[0] for p in pairs), sum(p[1] for p in pairs))
            ).without_defaults()
            | "Format" >> beam.ParDo(FormatWindow())
            | "WriteWindows" >> beam.io.WriteToText(known_args.output, file_name_suffix=".txt")
        )

        (
            results[ParseAndValidate.DEAD_LETTER]
            | "DeadToJson" >> beam.Map(json.dumps)
            | "WriteDead"
            >> beam.io.WriteToText(known_args.dead_letter_output, file_name_suffix=".jsonl")
        )


if __name__ == "__main__":
    run()