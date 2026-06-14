#!/usr/bin/env python3
"""SessionEnd hook: appends session cost, cwd, and token usage to ~/.claude/cost-session-summary.md"""
import json
import sys
import os
from datetime import datetime

try:
    data = json.load(sys.stdin)
except Exception:
    data = {}

session_id = data.get("session_id", "unknown")
cwd = data.get("cwd") or os.getcwd()
transcript_path = data.get("transcript_path", "")
ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# --- Cost: read from status line cache (written by statusline-command.sh) ---
cost_str = "N/A"
cache_file = f"/tmp/claude-cost-{session_id}.tmp"
try:
    with open(cache_file) as f:
        val = float(f.read().strip())
    cost_str = f"${val:.4f}"
    os.unlink(cache_file)  # clean up
except Exception:
    pass

# --- Tokens: parse transcript JSONL (accurate even through Portkey) ---
tokens_in = tokens_out = cache_read = cache_write = 0
slug = ""
model = ""
try:
    with open(transcript_path) as f:
        for line in f:
            try:
                obj = json.loads(line)
                if obj.get("type") == "assistant" and not obj.get("isSidechain"):
                    usage = (obj.get("message") or {}).get("usage") or {}
                    tokens_in    += usage.get("input_tokens", 0)
                    tokens_out   += usage.get("output_tokens", 0)
                    cache_read   += usage.get("cache_read_input_tokens", 0)
                    cache_write  += (
                        usage.get("cache_creation_input_tokens", 0)
                        + (usage.get("cache_creation") or {}).get("ephemeral_1h_input_tokens", 0)
                        + (usage.get("cache_creation") or {}).get("ephemeral_5m_input_tokens", 0)
                    )
                    if not slug:
                        slug = obj.get("slug", "")
                    if not model:
                        model = (obj.get("message") or {}).get("model", "")
            except Exception:
                pass
except Exception:
    pass

token_line = f"{tokens_in:,} in / {tokens_out:,} out"
if cache_read:
    token_line += f" / {cache_read:,} cache-read"
if cache_write:
    token_line += f" / {cache_write:,} cache-write"

entry = (
    f"\n## {ts}\n"
    f"- **Session**: {slug or session_id[:8]}\n"
    f"- **Directory**: {cwd}\n"
    + (f"- **Model**: {model}\n" if model else "")
    + f"- **Cost**: {cost_str}\n"
    f"- **Tokens**: {token_line}\n"
)

log_path = os.path.expanduser("~/.claude/cost-session-summary.md")
with open(log_path, "a") as f:
    f.write(entry)
