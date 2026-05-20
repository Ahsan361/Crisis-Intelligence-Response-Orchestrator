---
name: readme-writer
description: Write comprehensive technical documentation.
---

# README Writer Skill

## Instructions
1. **Accuracy:** Base all documentation explicitly on the real CIRO project files (e.g., `main.py`, `PROJECT_SPEC.md`, Flutter `lib/`). Do not invent generic architectural concepts.
2. **Visuals:** Utilize Markdown badges (for FastAPI, Supabase, Flutter, Gemini) and ASCII/Mermaid diagrams to visually break down architecture.
3. **Tone:** The tone should be technical, professional, and targeted toward hackathon judges. Emphasize "AI transparency", "Mechanism 4", and "multi-source ingestion".

## Constraints
- Never include raw API keys in README examples or setup blocks.
- Keep the root `README.md` concise—max 2 printed pages.

## Common Pitfalls
- **Outdated Schemas:** Documenting old data models. Always cross-reference `backend/models.py` to verify the current fields (e.g., ensuring `crisis_confidence` and `detected_language` are mentioned).
