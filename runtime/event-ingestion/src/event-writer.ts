import { createClient } from "@supabase/supabase-js";
import { stableStringify } from "./stable-json.js";
import type { DeadLetterInsert, EventWriteResult, JsonObject, OperatingEvent } from "./types.js";

type QueryResult = {
  data: JsonObject | null;
  error: SupabaseError | null;
};

type SupabaseError = {
  code?: string;
  message?: string;
  details?: string;
};

type SupabaseLike = {
  from(table: string): {
    insert(row: JsonObject): {
      select(columns?: string): {
        single(): Promise<QueryResult>;
      };
    };
    select(columns?: string): {
      eq(column: string, value: unknown): {
        limit(count: number): {
          maybeSingle(): Promise<QueryResult>;
        };
      };
    };
  };
};

export interface EventWriterOptions {
  client?: SupabaseLike;
  env?: NodeJS.ProcessEnv;
}

export async function writeValidatedEvent(
  event: OperatingEvent,
  options: EventWriterOptions = {}
): Promise<EventWriteResult> {
  const client = options.client ?? createSupabaseClient(options.env);
  const row = eventToInsert(event);
  const inserted = await client.from("events").insert(row).select("*").single();

  if (!inserted.error && inserted.data) {
    return { status: "inserted", row: inserted.data };
  }

  if (isDuplicateError(inserted.error)) {
    const existing = await client
      .from("events")
      .select("*")
      .eq("idempotency_key", event.idempotency_key)
      .limit(1)
      .maybeSingle();

    if (existing.error || !existing.data) {
      return {
        status: "dead_letter_prepared",
        dead_letter: prepareDeadLetter(event, existing.error ?? inserted.error)
      };
    }

    if (payloadsMatch(existing.data.payload, event.payload)) {
      return { status: "replayed", row: existing.data };
    }

    return {
      status: "conflict",
      message: `idempotency_key "${event.idempotency_key}" already exists with a different payload.`,
      existing: existing.data
    };
  }

  return {
    status: "dead_letter_prepared",
    dead_letter: prepareDeadLetter(event, inserted.error)
  };
}

export function createSupabaseClient(env: NodeJS.ProcessEnv = process.env): SupabaseLike {
  const supabaseUrl = env.SUPABASE_URL;
  const serviceRoleKey = env.SUPABASE_SERVICE_ROLE_KEY;

  if (!supabaseUrl || !serviceRoleKey) {
    throw new Error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY.");
  }

  return createClient(supabaseUrl, serviceRoleKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false
    }
  }) as unknown as SupabaseLike;
}

export function prepareDeadLetter(
  event: OperatingEvent,
  error: SupabaseError | null | undefined
): DeadLetterInsert {
  return {
    failed_event_type: event.event_type,
    source: event.source,
    idempotency_key: `dead-letter:${event.idempotency_key}`,
    status: "open",
    error_message: error?.message ?? "Unknown event write failure.",
    retry_count: 0,
    contact_id: event.contact_id ?? null,
    prospect_id: event.prospect_id ?? null,
    payload: {
      original_event: event,
      error: {
        code: error?.code ?? null,
        message: error?.message ?? null,
        details: error?.details ?? null
      }
    }
  };
}

function eventToInsert(event: OperatingEvent): JsonObject {
  return {
    occurred_at: event.occurred_at,
    event_type: event.event_type,
    source: event.source,
    idempotency_key: event.idempotency_key,
    contact_id: event.contact_id ?? null,
    prospect_id: event.prospect_id ?? null,
    actor: event.actor ?? null,
    summary: event.summary ?? null,
    payload: event.payload
  };
}

function isDuplicateError(error: SupabaseError | null | undefined): boolean {
  return error?.code === "23505";
}

function payloadsMatch(left: unknown, right: unknown): boolean {
  return stableStringify(left) === stableStringify(right);
}
