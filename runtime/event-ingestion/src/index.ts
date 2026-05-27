export { createEventValidator, loadSchema } from "./event-validator.js";
export { createSupabaseClient, prepareDeadLetter, writeValidatedEvent } from "./event-writer.js";
export type {
  DeadLetterInsert,
  EventWriteResult,
  JsonObject,
  OperatingEvent,
  ValidationFailure,
  ValidationResult,
  ValidationSuccess
} from "./types.js";
