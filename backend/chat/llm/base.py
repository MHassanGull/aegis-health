"""LLM provider interface — swap providers (Gemini / Claude / Ollama) by config."""


class LLMProvider:
    name = "base"

    def reply(self, system: str, history: list[dict]) -> str:
        """Return the assistant's reply.

        Args:
            system: the system prompt.
            history: ordered list of {"role": "user"|"assistant", "text": str}.
        """
        raise NotImplementedError
