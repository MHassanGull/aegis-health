"""Google Gemini provider (used now)."""
import json
import urllib.request
import urllib.error

from django.conf import settings

from .base import LLMProvider


class GeminiProvider(LLMProvider):
    name = "gemini"

    def reply(self, system: str, history: list[dict]) -> str:
        key = getattr(settings, "GEMINI_API_KEY", "")
        if not key:
            return ("The AI assistant isn’t set up yet. Add your free GEMINI_API_KEY to "
                    "backend/.env and restart the server.")
        model = getattr(settings, "GEMINI_MODEL", "gemini-2.0-flash")
        url = (f"https://generativelanguage.googleapis.com/v1beta/models/"
               f"{model}:generateContent?key={key}")

        contents = []
        for m in history:
            role = "model" if m["role"] == "assistant" else "user"
            contents.append({"role": role, "parts": [{"text": m["text"]}]})

        body = {
            "system_instruction": {"parts": [{"text": system}]},
            "contents": contents,
            "generationConfig": {"temperature": 0.6, "maxOutputTokens": 700},
        }
        req = urllib.request.Request(
            url, data=json.dumps(body).encode(),
            headers={"Content-Type": "application/json"})
        try:
            with urllib.request.urlopen(req, timeout=40) as r:
                data = json.loads(r.read().decode())
            return data["candidates"][0]["content"]["parts"][0]["text"].strip()
        except urllib.error.HTTPError as e:
            msg = e.read().decode()[:300]
            if e.code in (400, 403):
                return ("The AI key looks invalid or not enabled. Double-check your "
                        "GEMINI_API_KEY in backend/.env.")
            return f"Sorry, the assistant had a problem ({e.code})."
        except Exception:
            return "Sorry, I couldn’t reach the AI service right now. Please try again."
