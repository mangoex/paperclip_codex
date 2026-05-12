#!/usr/bin/env python3
"""Normalize stale Outreach handoff blockers in Paperclip.

This script is intentionally conservative. It never sends messages, creates
Closer tickets, or changes Closer status. With --apply it only marks an
Outreach issue done when the existing evidence proves the handoff is already
healthy.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sqlite3
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Any


DEFAULT_HOST = "paperclip-paperclip-app.yroec7.easypanel.host"
DEFAULT_COOKIE_DB = (
    Path.home() / "Library/Application Support/paperclip-desktop/Cookies"
)
NEGATIVE_MARKERS = (
    "delegated_to_conversationmanager",
    "external_messages_sent: false",
    "supabase_not_configured",
    "persistence_failed_after_provider_send",
    "missing_outreach_log_evidence",
)


def load_cookie(host: str, cookie_db: Path) -> str:
    env_cookie = os.getenv("PAPERCLIP_COOKIE")
    if env_cookie:
        return env_cookie

    if not cookie_db.exists():
        raise SystemExit(
            "No Paperclip cookie DB found. Set PAPERCLIP_COOKIE or pass --cookie-db."
        )

    with sqlite3.connect(cookie_db) as conn:
        row = conn.execute(
            """
            select name || '=' || value
            from cookies
            where host_key = ?
              and name = '__Secure-paperclip-default.session_token'
            limit 1
            """,
            (host,),
        ).fetchone()

    if not row:
        raise SystemExit("No Paperclip session cookie found for host.")
    return row[0]


class PaperclipClient:
    def __init__(self, host: str, cookie: str) -> None:
        self.base = f"https://{host}/api"
        self.host = host
        self.cookie = cookie

    def request(self, method: str, path: str, body: dict[str, Any] | None = None) -> Any:
        data = None if body is None else json.dumps(body).encode("utf-8")
        req = urllib.request.Request(
            f"{self.base}{path}",
            data=data,
            method=method,
            headers={
                "Cookie": self.cookie,
                "Content-Type": "application/json",
                "Origin": f"https://{self.host}",
                "Referer": f"https://{self.host}/",
            },
        )
        try:
            with urllib.request.urlopen(req, timeout=30) as res:
                raw = res.read()
        except urllib.error.HTTPError as exc:
            detail = exc.read().decode("utf-8", "replace")
            raise RuntimeError(f"{method} {path} failed: {exc.code} {detail}") from exc
        return json.loads(raw.decode("utf-8")) if raw else None

    def get_issue(self, issue_ref: str) -> dict[str, Any]:
        return self.request("GET", f"/issues/{urllib.parse.quote(issue_ref)}")

    def list_comments(self, issue_ref: str) -> list[dict[str, Any]]:
        return self.request("GET", f"/issues/{urllib.parse.quote(issue_ref)}/comments")

    def list_issues(
        self, company_id: str, status: str = "blocked", limit: int = 200
    ) -> list[dict[str, Any]]:
        query = urllib.parse.urlencode({"status": status, "limit": str(limit)})
        return self.request("GET", f"/companies/{company_id}/issues?{query}")

    def mark_done(self, issue_id: str) -> dict[str, Any]:
        return self.request("PATCH", f"/issues/{urllib.parse.quote(issue_id)}", {"status": "done"})


def text_blob(issue: dict[str, Any], comments: list[dict[str, Any]]) -> str:
    parts = [issue.get("title") or "", issue.get("description") or ""]
    for comment in comments:
        if isinstance(comment, dict):
            parts.append(comment.get("body") or "")
    return "\n".join(parts).lower()


def has_send_evidence(blob: str) -> bool:
    has_log = bool(re.search(r"outreach_log_ids:\s*(?:.|\n)*?(whatsapp|email):\s*['\"]?[^'\"\n{]+", blob))
    has_provider = "whatsapp_id:" in blob or "wamid." in blob or "email_id:" in blob
    has_sent_flag = "external_messages_sent: true" in blob
    return has_log and has_provider and has_sent_flag


def closer_refs(issue: dict[str, Any], blob: str) -> list[str]:
    refs: list[str] = []
    for match in re.finditer(r"HUM[A-Z]*-\d+", blob):
        refs.append(match.group(0))
    for related in issue.get("relatedWork", {}).get("outbound", []) or []:
        rel_issue = related.get("issue") or {}
        identifier = rel_issue.get("identifier")
        title = rel_issue.get("title") or ""
        if identifier and title.startswith("Closer: seguimiento"):
            refs.append(identifier)
    for item in issue.get("workProducts") or []:
        if isinstance(item, dict) and item.get("identifier"):
            refs.append(item["identifier"])
    return sorted(set(refs))


def evaluate(client: PaperclipClient, issue: dict[str, Any]) -> tuple[bool, str]:
    comments = client.list_comments(issue["identifier"])
    blob = text_blob(issue, comments)
    if issue.get("status") != "blocked":
        return False, "not_blocked"
    if "closer_status_not_confirmed_blocked" not in blob:
        return False, "different_block_reason"
    if any(marker in blob for marker in NEGATIVE_MARKERS):
        return False, "negative_marker_present"
    if not has_send_evidence(blob):
        return False, "missing_send_or_log_evidence"

    refs = closer_refs(issue, blob)
    if not refs:
        return False, "missing_closer_ref"

    for ref in refs:
        try:
            closer = client.get_issue(ref)
        except RuntimeError:
            continue
        if (closer.get("title") or "").startswith("Closer: seguimiento") and closer.get("status") == "blocked":
            return True, f"closer_blocked:{ref}"

    return False, "closer_not_confirmed_blocked"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default=DEFAULT_HOST)
    parser.add_argument("--cookie-db", type=Path, default=DEFAULT_COOKIE_DB)
    parser.add_argument("--company-id", default=os.getenv("PAPERCLIP_COMPANY_ID"))
    parser.add_argument("--root-issue", help="Optional issue ref used to discover company id.")
    parser.add_argument("--apply", action="store_true", help="Actually mark eligible Outreach issues done.")
    parser.add_argument("--limit", type=int, default=200)
    args = parser.parse_args()

    cookie = load_cookie(args.host, args.cookie_db)
    client = PaperclipClient(args.host, cookie)

    company_id = args.company_id
    if not company_id and args.root_issue:
        company_id = client.get_issue(args.root_issue)["companyId"]
    if not company_id:
        raise SystemExit("Pass --company-id or --root-issue.")

    issues = client.list_issues(company_id, limit=args.limit)
    candidates = [
        issue
        for issue in issues
        if (issue.get("title") or "").startswith("Outreach:")
    ]

    changed = 0
    for summary in candidates:
        issue = client.get_issue(summary["identifier"])
        ok, reason = evaluate(client, issue)
        line = f"{issue['identifier']} {issue['title']} -> {reason}"
        if ok and args.apply:
            client.mark_done(issue["id"])
            changed += 1
            line += " [DONE]"
        elif ok:
            line += " [DRY-RUN]"
        print(line)

    print(f"eligible_changed={changed} apply={args.apply}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
