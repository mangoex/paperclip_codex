export type JsonObject = Record<string, unknown>;

export interface OperatingEvent {
  event_type: string;
  source: string;
  idempotency_key: string;
  occurred_at: string;
  actor?: string | null;
  contact_id?: string | null;
  prospect_id?: string | null;
  summary?: string | null;
  payload: JsonObject;
}

export interface ValidationSuccess {
  ok: true;
  event: OperatingEvent;
}

export interface ValidationFailure {
  ok: false;
  errors: string[];
}

export type ValidationResult = ValidationSuccess | ValidationFailure;

export interface DeadLetterInsert {
  failed_event_type: string;
  source: string;
  idempotency_key: string;
  status: "open";
  error_message: string;
  retry_count: 0;
  contact_id?: string | null;
  prospect_id?: string | null;
  payload: JsonObject;
}

export type EventWriteResult =
  | { status: "inserted"; row: JsonObject }
  | { status: "replayed"; row: JsonObject }
  | { status: "conflict"; message: string; existing: JsonObject }
  | { status: "dead_letter_prepared"; dead_letter: DeadLetterInsert };
