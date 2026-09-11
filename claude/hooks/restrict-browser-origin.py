#!/usr/bin/env python3
"""PreToolUse hook for Playwright navigation: keep the browser on local origins.

Local dev URLs navigate freely; anything else prompts, so a driven browser
can't quietly wander onto a logged-in site with the user's real session.
"""

import json
import sys
from urllib.parse import urlparse

LOCAL_HOSTS = {"localhost", "127.0.0.1", "0.0.0.0", "::1", "host.docker.internal"}
LOCAL_SCHEMES = {"about", "file", "data", "chrome"}


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


def main():
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    url = (payload.get("tool_input") or {}).get("url")
    if not url:
        sys.exit(0)

    parsed = urlparse(url if "://" in url else f"http://{url}")
    if parsed.scheme in LOCAL_SCHEMES:
        decide("allow", f"{parsed.scheme}: URL, no network origin")

    host = (parsed.hostname or "").lower()
    if host in LOCAL_HOSTS or host.endswith(".localhost"):
        decide("allow", f"local origin: {host}")

    decide("ask", f"navigation leaves local origins: {host or url}")


if __name__ == "__main__":
    main()
