#!/usr/bin/env python3
"""PreToolUse hook for Bash: auto-allow curl against localhost, prompt for anything else.

Rationale: local dev servers get hit constantly during a session, but an
unreviewed curl to an external host can exfiltrate whatever is in the repo.
Commands that don't invoke curl fall through to the normal permission flow.
"""

import json
import re
import shlex
import sys

LOCAL_HOSTS = {"localhost", "127.0.0.1", "0.0.0.0", "::1", "[::1]", "host.docker.internal"}
URL_RE = re.compile(r"^(?:https?://)?(?:[^/@\s]*@)?(\[[^\]]+\]|[^/:?\s]+)")


def decide(decision, reason):
    json.dump(
        {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": decision,
                "permissionDecisionReason": reason,
            }
        },
        sys.stdout,
    )
    sys.exit(0)


def host_of(token):
    m = URL_RE.match(token)
    return m.group(1).lower() if m else None


def main():
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    command = (payload.get("tool_input") or {}).get("command") or ""
    if not re.search(r"\bcurl\b", command):
        sys.exit(0)

    try:
        tokens = shlex.split(command)
    except ValueError:
        sys.exit(0)

    hosts = []
    for token in tokens:
        if token.startswith("-"):
            continue
        if token.startswith(("http://", "https://")) or re.match(
            r"^(localhost|\d{1,3}(\.\d{1,3}){3}|\[[^\]]+\])(:\d+)?(/|$)", token
        ):
            host = host_of(token)
            if host:
                hosts.append(host)

    if not hosts:
        sys.exit(0)

    remote = [h for h in hosts if h.split(":")[0] not in LOCAL_HOSTS]
    if remote:
        decide("ask", f"curl targets a non-local host: {', '.join(sorted(set(remote)))}")
    decide("allow", "curl targets localhost only")


if __name__ == "__main__":
    main()
