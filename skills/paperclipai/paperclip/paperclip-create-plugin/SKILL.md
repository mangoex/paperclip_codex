---
name: "paperclip-create-plugin"
description: "Create Paperclip/Codex plugins with MCP server configuration and bundled skills. Use when the user asks to create a plugin, package an MCP server, add .codex-plugin/plugin.json, add .mcp.json, or create the skills needed for a tool integration."
slug: "paperclip-create-plugin"
metadata:
  sources:
    -
      kind: "github-dir"
      commit: null
      path: "skills/paperclip-create-plugin"
      repo: "paperclipai/paperclip"
      trackingRef: "master"
      url: "https://github.com/paperclipai/paperclip/tree/master/skills/paperclip-create-plugin"
key: "paperclipai/paperclip/paperclip-create-plugin"
---

# Paperclip Plugin Creation

## Overview

Use this skill to create a local plugin that packages one or more skills plus optional MCP server configuration for Codex/Paperclip-style agent workflows.

## Default Structure

Create the plugin as:

```text
plugins/<plugin-name>/
├── .codex-plugin/plugin.json
├── .mcp.json
├── assets/
├── scripts/
└── skills/
    └── <skill-name>/
        ├── SKILL.md
        ├── agents/openai.yaml
        └── references/
```

Use `skill-creator` to initialize new skills. Keep every `SKILL.md` concise and move detailed setup, schemas, tool lists, or examples into `references/`.

## Workflow

1. Resolve the source tool or MCP server from official docs or repository files.
2. Create `.codex-plugin/plugin.json` with name, version, description, repository, license, skills path, MCP path, and UI interface metadata.
3. Create `.mcp.json` with the smallest stable server command. Prefer official package names and avoid experimental flags by default.
4. Add only the skills needed to operate the plugin safely:
   - umbrella skill for routing and setup
   - operation skill for the main workflow
   - auth/session skill when accounts or credentials are involved
   - debug/evidence skill when inspection or proof is important
5. Add scripts only for repeated deterministic checks.
6. Validate each skill with `skill-creator/scripts/quick_validate.py`.
7. Validate JSON files and run a lightweight local check script when available.

## MCP Rules

- Use official MCP commands exactly unless there is a local reason to wrap them.
- Keep secrets out of `.mcp.json`; reference environment variables instead.
- Do not enable write-heavy or privileged behavior by default if optional flags can be enabled per task.
- Document optional capabilities in skill references rather than expanding the default config.

## Output

End with the created plugin path, skills created, validation status, and any remaining installation or reload step the user must perform before the MCP tools appear.
