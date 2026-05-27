import assert from "node:assert/strict";
import test from "node:test";
import { createEventValidator } from "../src/event-validator.js";
import { n8nOutboundProspectingToEvent } from "../src/n8n-transformer.js";

test("transforms n8n outbound prospecting payload into a valid operating event", () => {
  const event = n8nOutboundProspectingToEvent(
    {
      request_id: "n8n-test-001",
      vertical: "dentistas",
      city: "Culiacan",
      country: "Mexico",
      requested_count: 3,
      requested_by: "miguel",
      external_ids: {
        n8n_execution_id: "exec-001"
      }
    },
    new Date("2026-05-27T17:00:00.000Z")
  );

  assert.equal(event.event_type, "outbound_prospecting_requested");
  assert.equal(event.idempotency_key, "n8n-staging:outbound_prospecting_requested:n8n-test-001");
  assert.equal(event.occurred_at, "2026-05-27T17:00:00.000Z");
  assert.equal(event.payload.request_id, "n8n-test-001");
  assert.deepEqual(event.payload.external_ids, {
    n8n_execution_id: "exec-001",
    environment: "staging"
  });

  const validation = createEventValidator().validate(event);
  assert.equal(validation.ok, true);
});

test("keeps explicit n8n idempotency_key when provided", () => {
  const event = n8nOutboundProspectingToEvent({
    request_id: "n8n-test-002",
    vertical: "dentistas",
    city: "Culiacan",
    country: "Mexico",
    requested_count: 1,
    requested_by: "miguel",
    idempotency_key: "manual-shadow-test:provided-key"
  });

  assert.equal(event.idempotency_key, "manual-shadow-test:provided-key");
});
