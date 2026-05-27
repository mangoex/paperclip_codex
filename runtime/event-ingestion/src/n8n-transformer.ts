import type { JsonObject, OperatingEvent } from "./types.js";

export interface N8nOutboundProspectingRequest {
  request_id: string;
  vertical: string;
  city: string;
  country: string;
  requested_count: number;
  requested_by: string;
  source?: string;
  idempotency_key?: string;
  occurred_at?: string;
  actor?: string | null;
  summary?: string | null;
  environment?: string;
  external_ids?: JsonObject;
}

export function n8nOutboundProspectingToEvent(
  input: N8nOutboundProspectingRequest,
  now = new Date()
): OperatingEvent {
  const source = input.source ?? "n8n_staging_webhook";
  const environment = input.environment ?? "staging";

  return {
    event_type: "outbound_prospecting_requested",
    source,
    idempotency_key:
      input.idempotency_key ?? `n8n-staging:outbound_prospecting_requested:${input.request_id}`,
    occurred_at: input.occurred_at ?? now.toISOString(),
    actor: input.actor ?? "n8n_staging",
    summary: input.summary ?? "n8n staging outbound prospecting request.",
    payload: {
      request_id: input.request_id,
      vertical: input.vertical,
      city: input.city,
      country: input.country,
      requested_count: input.requested_count,
      requested_by: input.requested_by,
      external_ids: {
        ...(input.external_ids ?? {}),
        environment
      }
    }
  };
}
