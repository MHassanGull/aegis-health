"""Local Ollama provider (ready for a 7B model running on the laptop).

Switch on with: LLM_PROVIDER=ollama
Configure OLLAMA_URL (default http://localhost:11434) and OLLAMA_MODEL (e.g. llama3, mistral).
"""
import json
import urllib.request

from django.conf import settings

from .base import LLMProvider


class OllamaProvider(LLMProvider):
    name = "ollama"

    def reply(self, system: str, history: list[dict]) -> str:
        base = getattr(settings, "OLLAMA_URL", "http://localhost:11434")
        model = getattr(settings, "OLLAMA_MODEL", "llama3")
        messages = [{"role": "system", "content": system}]
        for m in history:
            messages.append({"role": m["role"], "content": m["text"]})
        body = {"model": model, "messages": messages, "stream": False}
        req = urllib.request.Request(
            f"{base}/api/chat",
            data=json.dumps(body).encode(),
            headers={"Content-Type": "application/json"})
        try:
            with urllib.request.urlopen(req, timeout=120) as r:
                data = json.loads(r.read().decode())
            return data["message"]["content"].strip()
        except Exception:
            return ("Couldn’t reach the local Ollama model. Is `ollama serve` running and the "
                    "model pulled?")
