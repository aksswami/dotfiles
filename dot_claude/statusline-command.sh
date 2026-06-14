#!/bin/bash
input=$(cat)

# Cache cost+tokens per session for SessionEnd hook
_session_id=$(echo "$input" | jq -r '.session_id // empty')
_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
if [ -n "$_session_id" ] && [ -n "$_cost" ]; then
  echo "$_cost" > "/tmp/claude-cost-${_session_id}.tmp"
fi

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "?"')
model=$(echo "$input" | jq -r '.model.display_name // "unknown model"')

# ANSI color codes
reset='\033[0m'
bold='\033[1m'
green='\033[32m'
blue='\033[34m'
purple='\033[35m'
red='\033[31m'
white='\033[37m'
cyan='\033[36m'

# Git info
git_info=""
branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
         || GIT_OPTIONAL_LOCKS=0 git -C "$cwd" describe HEAD 2>/dev/null \
         || echo "")

if [ -n "$branch" ]; then
  git_status_str=""
  if GIT_OPTIONAL_LOCKS=0 git -C "$cwd" rev-parse --quiet --verify HEAD >/dev/null 2>&1; then
    if ! GIT_OPTIONAL_LOCKS=0 git -C "$cwd" diff-index --quiet HEAD -- 2>/dev/null; then
      porcelain=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" status --porcelain 2>/dev/null)
      # Check for staged additions
      echo "$porcelain" | grep -qE "^[MADRCU]" && git_status_str="${git_status_str}$(printf "${green}✚${reset}")"
      # Check for deleted
      echo "$porcelain" | grep -q " D" && git_status_str="${git_status_str}$(printf "${red}✖${reset}")"
      # Check for modified
      echo "$porcelain" | grep -qE "M" && git_status_str="${git_status_str}$(printf "${green}✱${reset}")"
      # Check for renamed
      echo "$porcelain" | grep -qE "R" && git_status_str="${git_status_str}$(printf "${purple}➜${reset}")"
      # Check for untracked
      echo "$porcelain" | grep -q "??" && git_status_str="${git_status_str}$(printf "${red}≠${reset}")"
    else
      git_status_str="$(printf "${green}:${reset}")"
    fi
  fi
  git_info="$(printf "${white}(git${git_status_str}${bold}${blue}${branch}${reset}${white})${reset}")"
fi

# Context window token counts: "38k / 200k (19%)"
# Use pre-calculated used_percentage to derive absolute count, so both values are consistent.
# current_usage.input_tokens is only the last API call snapshot and can read as a tiny number
# when the status line fires between turns.
ctx_str=""
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$ctx_size" ] && [ -n "$used_pct" ]; then
  # Derive absolute token count from the percentage so count and % are always in sync
  cur_input=$(echo "$used_pct $ctx_size" | awk '{printf "%.0f", $1 / 100 * $2}')
  if [ "$cur_input" -ge 1000 ]; then
    used_display="$(printf '%dk' "$(( cur_input / 1000 ))")"
  else
    used_display="${cur_input}"
  fi
  if [ "$ctx_size" -ge 1000 ]; then
    total_display="$(printf '%dk' "$(( ctx_size / 1000 ))")"
  else
    total_display="${ctx_size}"
  fi
  pct_display="$(printf '%.0f' "$used_pct")%"
  ctx_str="ctx: ${used_display} / ${total_display} (${pct_display})"
fi

# Cost display
cost_str=""
total_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
[ -n "$total_cost" ] && cost_str="$(printf '$%.2f' "$total_cost")"

# Assemble: ❰(git status+branch)❱  model  ctx: 38k / 200k  $X.XX
line="${bold}${white}❰${reset}%s${bold}${white}❱${reset}  %s"
args=("$git_info" "$model")
if [ -n "$ctx_str" ]; then
  line="${line}  ${cyan}%s${reset}"
  args+=("$ctx_str")
fi
if [ -n "$cost_str" ]; then
  line="${line}  ${cyan}%s${reset}"
  args+=("$cost_str")
fi
printf "$line" "${args[@]}"
