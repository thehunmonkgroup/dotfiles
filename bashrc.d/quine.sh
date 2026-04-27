# Quine Configuration
# Copy this file to .env and fill in your values:
#   cp .env.example .env
#
# Then source it before running quine:
#   source .env
#   quine "Hello"
#
# IMPORTANT: Every line must start with 'export' so that
# 'source .env' exports variables to child processes.

# ── Required (all four must be set) ──────────────────────
export QUINE_MODEL_ID=claude-sonnet-4-6
export QUINE_API_TYPE=anthropic
export QUINE_API_BASE=https://api.anthropic.com
export QUINE_API_KEY=${ANTHROPIC_API_KEY}

# ── Optional: Provider/Context ──────────────────────────
# export QUINE_PROVIDER=anthropic     # Provider name for Harbor bench scripts
# export QUINE_CONTEXT_WINDOW=128000  # Context window size in tokens

# ── Optional: Physics Limits (0 = disabled/unlimited) ───
export QUINE_MAX_DEPTH=10            # Max recursion depth
export QUINE_MAX_AGENTS=10           # Max registered agents
export QUINE_MAX_CONCURRENT=10       # Max concurrent inference slots
export QUINE_MAX_TURNS=50            # Max number of sh executions

# ── Optional: Budget/Prompt Policies ─────────────────────
# export QUINE_TURN_EXHAUSTION_POLICY=hard_fail   # hard_fail | near_death_exec
# export QUINE_PROMPT_METAPHOR=off    # off | thermodynamic

# ── Optional: Runtime I/O + Shell ────────────────────────
# export QUINE_DATA_DIR=.quine/       # Session log directory
# export QUINE_SH_TIMEOUT=600         # Shell command timeout (seconds)

# ── Example: OpenAI Responses API with Codex OAuth ───────
# export QUINE_PROVIDER=openai
# export QUINE_MODEL_ID=gpt-5.1-codex-mini
# export QUINE_API_TYPE=openai-responses
# export QUINE_API_BASE=https://chatgpt.com/backend-api/codex
# export QUINE_API_KEY=codex-oauth
# export QUINE_CONFIG_DIR="$HOME/.config/quine"
