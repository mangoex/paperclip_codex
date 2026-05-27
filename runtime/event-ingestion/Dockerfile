FROM node:22-bookworm-slim AS base

WORKDIR /app

COPY runtime/event-ingestion/package*.json ./runtime/event-ingestion/

RUN cd runtime/event-ingestion && npm ci

COPY contracts ./contracts
COPY runtime/event-ingestion/tsconfig*.json ./runtime/event-ingestion/
COPY runtime/event-ingestion/src ./runtime/event-ingestion/src

RUN cd runtime/event-ingestion \
  && npm run build \
  && npm prune --omit=dev

WORKDIR /app/runtime/event-ingestion

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

CMD ["npm", "run", "start"]
