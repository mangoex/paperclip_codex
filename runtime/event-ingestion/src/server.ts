import http from "node:http";
import dotenv from "dotenv";
import { createEventValidator } from "./event-validator.js";
import { prepareDeadLetter, writeValidatedEvent } from "./event-writer.js";
import type { JsonObject, OperatingEvent } from "./types.js";

dotenv.config({ path: ".env.local", quiet: true });

const port = Number(process.env.PORT ?? 3000);
const validator = createEventValidator();

const server = http.createServer(async (request, response) => {
  try {
    if (request.method === "GET" && request.url === "/health") {
      sendJson(response, 200, {
        status: "ok",
        service: "event-ingestion",
        mode: "staging"
      });
      return;
    }

    if (request.method === "POST" && request.url === "/events") {
      const body = await readJson(request);
      const validation = validator.validate(body);

      if (!validation.ok) {
        sendJson(response, 400, {
          status: "validation_error",
          errors: validation.errors
        });
        return;
      }

      const result = await safeWrite(validation.event);
      if (result.status === "inserted") {
        sendJson(response, 201, {
          status: "inserted",
          idempotency_key: validation.event.idempotency_key,
          event_type: validation.event.event_type
        });
        return;
      }

      if (result.status === "replayed") {
        sendJson(response, 200, {
          status: "replayed",
          idempotency_key: validation.event.idempotency_key,
          event_type: validation.event.event_type
        });
        return;
      }

      if (result.status === "conflict") {
        sendJson(response, 409, {
          status: "conflict",
          idempotency_key: validation.event.idempotency_key,
          event_type: validation.event.event_type,
          message: result.message
        });
        return;
      }

      sendJson(response, 500, {
        status: "dead_letter_prepared",
        idempotency_key: validation.event.idempotency_key,
        event_type: validation.event.event_type
      });
      return;
    }

    sendJson(response, 404, {
      status: "not_found"
    });
  } catch {
    sendJson(response, 500, {
      status: "internal_error"
    });
  }
});

server.listen(port, () => {
  console.log(`event-ingestion listening on port ${port}`);
});

async function safeWrite(event: OperatingEvent) {
  try {
    return await writeValidatedEvent(event);
  } catch {
    return {
      status: "dead_letter_prepared" as const,
      dead_letter: prepareDeadLetter(event, {
        message: "Unhandled event write failure."
      })
    };
  }
}

async function readJson(request: http.IncomingMessage): Promise<unknown> {
  const raw = await new Promise<string>((resolve, reject) => {
    let body = "";
    request.setEncoding("utf8");
    request.on("data", (chunk) => {
      body += chunk;
      if (body.length > 1_000_000) {
        request.destroy();
        reject(new Error("Request body too large."));
      }
    });
    request.on("end", () => resolve(body));
    request.on("error", reject);
  });

  return JSON.parse(raw) as unknown;
}

function sendJson(response: http.ServerResponse, statusCode: number, body: JsonObject): void {
  response.writeHead(statusCode, {
    "Content-Type": "application/json"
  });
  response.end(JSON.stringify(body));
}
