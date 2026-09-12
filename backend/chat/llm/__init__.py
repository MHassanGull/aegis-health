"""LLM provider factory — picks the provider from settings.LLM_PROVIDER."""
from django.conf import settings

from .base import LLMProvider
from .gemini import GeminiProvider
from .claude import ClaudeProvider
from .ollama import OllamaProvider

_PROVIDERS = {
    "gemini": GeminiProvider,
    "claude": ClaudeProvider,
    "ollama": OllamaProvider,
}


def get_provider() -> LLMProvider:
    name = getattr(settings, "LLM_PROVIDER", "gemini").lower()
    return _PROVIDERS.get(name, GeminiProvider)()
