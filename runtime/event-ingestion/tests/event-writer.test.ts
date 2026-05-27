import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";
import { writeValidatedEvent } from "../src/event-writer.js";
import type { JsonObject, OperatingEvent } from "../src/types.js";

test("inserts a new validated event", async () => {
  const event = readValidEvent();
  const client = new FakeSupabaseClient();

  const result = await writeValidatedEvent(event, { client });

  assert.equal(result.status, "inserted");
  assert.equal(client.events.length, 1);
});

test("treats duplicate idempotency_key with same payload as replay", async () => {
  const event = readValidEvent();
  const client = new FakeSupabaseClient();

  await writeValidatedEvent(event, { client });
  const replay = await writeValidatedEvent(event, { client });

  assert.equal(replay.status, "replayed");
  assert.equal(client.events.length, 1);
});

test("returns conflict for duplicate idempotency_key with different payload", async () => {
  const event = readValidEvent();
  const client = new FakeSupabaseClient();
  await writeValidatedEvent(event, { client });

  const changedEvent: OperatingEvent = {
    ...event,
    payload: {
      ...event.payload,
      requested_count: 9
    }
  };
  const result = await writeValidatedEvent(changedEvent, { client });

  assert.equal(result.status, "conflict");
  if (result.status === "conflict") {
    assert.match(result.message, /different payload/);
  }
  assert.equal(client.events.length, 1);
});

test("prepares dead-letter payload on simulated write error", async () => {
  const event = readValidEvent();
  const client = new FakeSupabaseClient({ failInsert: true });

  const result = await writeValidatedEvent(event, { client });

  assert.equal(result.status, "dead_letter_prepared");
  if (result.status === "dead_letter_prepared") {
    assert.equal(result.dead_letter.failed_event_type, "outbound_prospecting_requested");
    assert.equal(result.dead_letter.source, event.source);
    assert.equal(result.dead_letter.idempotency_key, `dead-letter:${event.idempotency_key}`);
    assert.equal(result.dead_letter.payload.original_event, event);
  }
});

class FakeSupabaseClient {
  readonly events: JsonObject[] = [];
  private readonly failInsert: boolean;

  constructor(options: { failInsert?: boolean } = {}) {
    this.failInsert = Boolean(options.failInsert);
  }

  from(table: string) {
    assert.equal(table, "events");
    const client = this;

    return {
      insert(row: JsonObject) {
        return {
          select() {
            return {
              async single() {
                if (client.failInsert) {
                  return {
                    data: null,
                    error: { code: "XX000", message: "simulated write failure" }
                  };
                }

                const duplicate = client.events.find(
                  (item) => item.idempotency_key === row.idempotency_key
                );

                if (duplicate) {
                  return {
                    data: null,
                    error: { code: "23505", message: "duplicate key value violates unique constraint" }
                  };
                }

                const inserted = { id: `event-${client.events.length + 1}`, ...row };
                client.events.push(inserted);
                return { data: inserted, error: null };
              }
            };
          }
        };
      },
      select() {
        return {
          eq(column: string, value: unknown) {
            return {
              limit() {
                return {
                  async maybeSingle() {
                    const existing = client.events.find((item) => item[column] === value) ?? null;
                    return { data: existing, error: null };
                  }
                };
              }
            };
          }
        };
      }
    };
  }
}

function readValidEvent(): OperatingEvent {
  const samplePath = path.resolve(process.cwd(), "samples", "outbound_prospecting_requested.valid.json");
  return JSON.parse(fs.readFileSync(samplePath, "utf8")) as OperatingEvent;
}
