import fs from "node:fs";
import path from "node:path";
import { createEventValidator } from "../src/event-validator.js";

const sampleArg = process.argv[2];

if (!sampleArg) {
  console.error("Usage: npm run validate:sample -- samples/outbound_prospecting_requested.valid.json");
  process.exitCode = 1;
} else {
  const samplePath = path.resolve(process.cwd(), sampleArg);
  const sample = JSON.parse(fs.readFileSync(samplePath, "utf8"));
  const validator = createEventValidator();
  const result = validator.validate(sample);

  if (result.ok) {
    console.log(`VALID ${result.event.event_type} ${result.event.idempotency_key}`);
  } else {
    console.error("INVALID event");
    for (const error of result.errors) {
      console.error(`- ${error}`);
    }
    process.exitCode = 1;
  }
}
