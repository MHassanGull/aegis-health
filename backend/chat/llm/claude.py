"""Anthropic Claude provider (ready for when an ANTHROPIC_API_KEY is added).

Switch on with: LLM_PROVIDER=claude in backend/.env
Model is configurable via CLAUDE_MODEL (default: claude-haiku-4-5).
"""
import json
import urllib.request
import urllib.error

from django.conf import settings

from .base import LLMProvider


class ClaudeProvider(LLMProvider):
    name = "claude"

    def reply(self, system: str, history: list[dict]) -> str:
        key = getattr(settings, "ANTHROPIC_API_KEY", "")
        if not key:
            return ("Claude isn’t configured. Add ANTHROPIC_API_KEY to backend/.env and "
                    "set LLM_PROVIDER=claude.")
        model = getattr(settings, "CLAUDE_MODEL", "claude-haiku-4-5")
        messages = [{"role": m["role"], "content": m["text"]} for m in history]
        body = {"model": model, "max_tokens": 800, "system": system, "messages": messages}
        req = urllib.request.Request(
            "https://api.anthropic.com/v1/messages",
            data=json.dumps(body).encode(),
            headers={
                "x-api-key": key,
                "anthropic-version": "2023-06-01",
                "content-type": "application/json",
            },
        )
        try:
            with urllib.request.urlopen(req, timeout=40) as r:
                data = json.loads(r.read().decode())
            return data["content"][0]["text"].strip()
        except urllib.error.HTTPError as e:
            return f"Sorry, Claude had a problem ({e.code})."
        except Exception:
            return "Sorry, I couldn’t reach Claude right now."
