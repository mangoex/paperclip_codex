import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";
import { createEventValidator } from "../src/event-validator.js";
import type { OperatingEvent } from "../src/types.js";

const validator = createEventValidator();

test("validates outbound_prospecting_requested", () => {
  const event = readSample("outbound_prospecting_requested.valid.json");
  const result = validator.validate(event);

  assert.equal(result.ok, true);
  if (result.ok) {
    assert.equal(result.event.event_type, "outbound_prospecting_requested");
  }
});

test("rejects missing required payload field", () => {
  const event = readSample("outbound_prospecting_requested.invalid.json");
  const result = validator.validate(event);

  assert.equal(result.ok, false);
  if (!result.ok) {
    assert.match(result.errors.join("\n"), /requested_by is required/);
  }
});

test("rejects unknown event_type", () => {
  const event: OperatingEvent = {
    ...readSample("outbound_prospecting_requested.valid.json"),
    event_type: "unknown_shadow_event"
  };
  const result = validator.validate(event);

  assert.equal(result.ok, false);
  if (!result.ok) {
    assert.match(result.errors.join("\n"), /Unknown event_type "unknown_shadow_event"/);
  }
});

function readSample(fileName: string): OperatingEvent {
  const samplePath = path.resolve(process.cwd(), "samples", fileName);
  return JSON.parse(fs.readFileSync(samplePath, "utf8")) as OperatingEvent;
}
