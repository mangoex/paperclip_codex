import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { Ajv2020, type ErrorObject, type ValidateFunction } from "ajv/dist/2020.js";
import * as addFormatsModule from "ajv-formats";
import type { OperatingEvent, ValidationResult } from "./types.js";

type EventSchema = {
  $schema?: string;
  $id?: string;
  oneOf?: Array<{
    properties?: {
      event_type?: { const?: string };
    };
  }>;
  $defs?: Record<string, unknown>;
  properties?: Record<string, unknown>;
  [key: string]: unknown;
};

export interface EventValidator {
  validate(input: unknown): ValidationResult;
  knownEventTypes: string[];
}

export function createEventValidator(schemaPath = defaultSchemaPath()): EventValidator {
  const schema = loadSchema(schemaPath);
  const knownEventTypes = extractEventTypes(schema);
  const ajv = new Ajv2020({ allErrors: true, strict: false });
  addAjvFormats(ajv);

  const envelopeSchema = {
    ...schema,
    $id: undefined,
    oneOf: undefined,
    properties: {
      ...schema.properties,
      payload: { type: "object" }
    }
  };

  const validateEnvelope = ajv.compile(envelopeSchema);
  const validateFullContract = ajv.compile(schema);
  const payloadValidators = new Map<string, ValidateFunction>();

  for (const eventType of knownEventTypes) {
    payloadValidators.set(
      eventType,
      ajv.compile({
        $schema: schema.$schema,
        $defs: schema.$defs,
        $ref: `#/$defs/${eventType}`
      })
    );
  }

  return {
    knownEventTypes,
    validate(input: unknown): ValidationResult {
      const errors: string[] = [];

      if (!isObject(input)) {
        return { ok: false, errors: ["Event must be a JSON object."] };
      }

      const eventType = typeof input.event_type === "string" ? input.event_type : undefined;

      if (!validateEnvelope(input)) {
        errors.push(...formatErrors(validateEnvelope.errors));
      }

      if (eventType && !knownEventTypes.includes(eventType)) {
        errors.push(`Unknown event_type "${eventType}". Known event types: ${knownEventTypes.join(", ")}.`);
      }

      const validatePayload = eventType ? payloadValidators.get(eventType) : undefined;
      if (validatePayload && !validatePayload(input.payload)) {
        errors.push(...formatErrors(validatePayload.errors, "/payload"));
      }

      if (errors.length > 0) {
        return { ok: false, errors: unique(errors) };
      }

      if (!validateFullContract(input)) {
        return { ok: false, errors: unique(formatErrors(validateFullContract.errors)) };
      }

      return { ok: true, event: input as unknown as OperatingEvent };
    }
  };
}

export function loadSchema(schemaPath = defaultSchemaPath()): EventSchema {
  return JSON.parse(fs.readFileSync(schemaPath, "utf8")) as EventSchema;
}

function defaultSchemaPath(): string {
  const currentDir = path.dirname(fileURLToPath(import.meta.url));
  const candidates = [
    process.env.EVENT_SCHEMA_PATH,
    path.resolve(process.cwd(), "../../contracts/events.schema.json"),
    path.resolve(currentDir, "../../../contracts/events.schema.json"),
    path.resolve(currentDir, "../../contracts/events.schema.json")
  ].filter((candidate): candidate is string => Boolean(candidate));

  const found = candidates.find((candidate) => fs.existsSync(candidate));
  if (!found) {
    throw new Error("Could not find contracts/events.schema.json. Set EVENT_SCHEMA_PATH if needed.");
  }

  return found;
}

function extractEventTypes(schema: EventSchema): string[] {
  return (schema.oneOf ?? [])
    .map((item) => item.properties?.event_type?.const)
    .filter((value): value is string => typeof value === "string")
    .sort();
}

function formatErrors(errors: ErrorObject[] | null | undefined, prefix = ""): string[] {
  return (errors ?? [])
    .filter((error) => error.keyword !== "oneOf" && error.keyword !== "const")
    .map((error) => {
      const pathLabel = `${prefix}${error.instancePath || ""}` || "/";
      if (error.keyword === "required") {
        const missing = String(error.params.missingProperty);
        return `${pathLabel}/${missing} is required.`;
      }

      return `${pathLabel} ${error.message ?? "is invalid"}.`;
    });
}

function isObject(value: unknown): value is Record<string, unknown> {
  return Boolean(value) && typeof value === "object" && !Array.isArray(value);
}

function unique(values: string[]): string[] {
  return [...new Set(values)];
}

function addAjvFormats(ajv: Ajv2020): void {
  const plugin =
    "default" in addFormatsModule
      ? (addFormatsModule.default as unknown as (target: Ajv2020) => void)
      : (addFormatsModule as unknown as (target: Ajv2020) => void);
  plugin(ajv);
}
