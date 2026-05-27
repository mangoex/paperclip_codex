import fs from "node:fs";
import path from "node:path";
import dotenv from "dotenv";
import { createEventValidator } from "../src/event-validator.js";
import { n8nOutboundProspectingToEvent } from "../src/n8n-transformer.js";
import { writeValidatedEvent } from "../src/event-writer.js";
import type { N8nOutboundProspectingRequest } from "../src/n8n-transformer.js";

dotenv.config({ path: path.resolve(process.cwd(), ".env.local"), quiet: true });

const sampleArg = process.argv[2];

if (!sampleArg) {
  console.error("Usage: tsx scripts/write-sample-to-staging.ts samples/n8n_outbound_prospecting_requested.valid.json");
  process.exitCode = 1;
} else {
  const supabaseUrl = process.env.SUPABASE_URL;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!supabaseUrl || !serviceRoleKey) {
    throw new Error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in .env.local.");
  }

  if (!supabaseUrl.includes("nloytkdjbhoozjrhrpxq")) {
    throw new Error("SUPABASE_URL does not match the authorized Humanio Staging project ref.");
  }

  const samplePath = path.resolve(process.cwd(), sampleArg);
  const n8nPayload = JSON.parse(fs.readFileSync(samplePath, "utf8")) as N8nOutboundProspectingRequest;
  const event = n8nOutboundProspectingToEvent(n8nPayload);
  const validator = createEventValidator();
  const validation = validator.validate(event);

  if (!validation.ok) {
    console.error("validation_error");
    for (const error of validation.errors) {
      console.error(`- ${error}`);
    }
    process.exitCode = 1;
  } else {
    const result = await writeValidatedEvent(validation.event);
    console.log(result.status);

    if (result.status === "conflict") {
      process.exitCode = 2;
    }
  }
}
