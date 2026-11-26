#!/usr/bin/env bash
set -u

ROOT="$(cd "$(dirname "$0")" && pwd)"
GH="git@github.com:xsp4ce"
HOST="$(hostname -s 2>/dev/null || hostname)"
CLAUDE_DIR="$HOME/.claude"
MEMORY_KEY="$(printf '%s' "$ROOT" | sed 's/[^a-zA-Z0-9]/-/g')"
MEMORY_LINK="$CLAUDE_DIR/projects/$MEMORY_KEY/memory"
SETTINGS_LINK="$CLAUDE_DIR/settings.json"

CODE_REPOS="creditos_horizonte/backend:creditos-horizonte-backend:dev:main creditos_horizonte/frontend:creditos-horizonte-frontend:dev:main quipu:quipu:dev:main"
DATA_REPOS="creditos_horizonte/docs:creditos-horizonte-docs:main .:claudehome-config:main"

red() { printf '\033[31m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
title() { printf '\n\033[1m== %s\033[0m\n' "$*"; }

field() { printf '%s' "$1" | cut -d: -f"$2"; }

is_dirty() { [ -n "$(git -C "$1" status --porcelain)" ]; }

current_branch() { git -C "$1" rev-parse --abbrev-ref HEAD; }

link_to_repo() {
  local link="$1" target="$2"
  mkdir -p "$(dirname "$link")" "$(dirname "$target")"
  if [ -L "$link" ]; then
    green "ok: $link"
    return
  fi
  if [ -e "$link" ]; then
    if [ ! -e "$target" ] || [ -z "$(ls -A "$target" 2>/dev/null)" ]; then
      rm -rf "$target"
      mv "$link" "$target"
    else
      mv "$link" "$link.bak-$(date +%Y%m%d%H%M%S)"
      red "existing $link moved to backup"
    fi
  fi
  ln -s "$target" "$link"
  green "linked: $link -> $target"
}

cmd_setup() {
  title "clone"
  for entry in $CODE_REPOS $DATA_REPOS; do
    local path name branch
    path="$(field "$entry" 1)"; name="$(field "$entry" 2)"; branch="$(field "$entry" 3)"
    [ "$path" = "." ] && continue
    if [ -d "$ROOT/$path/.git" ]; then
      green "ok: $path"
    else
      git clone -b "$branch" "$GH/$name.git" "$ROOT/$path" || red "clone failed: $path"
    fi
  done
  title "links"
  link_to_repo "$MEMORY_LINK" "$ROOT/claude/memory"
  link_to_repo "$SETTINGS_LINK" "$ROOT/claude/settings.json"
  title "secrets (copy manually, never in git)"
  for f in creditos_horizonte/frontend/.env creditos_horizonte/docs/credentials.txt quipu/.env; do
    if [ -e "$ROOT/$f" ]; then green "ok: $f"; else red "missing: $f"; fi
  done
}

cmd_pull() {
  for entry in $DATA_REPOS $CODE_REPOS; do
    local path
    path="$(field "$entry" 1)"
    title "$path"
    [ -d "$ROOT/$path/.git" ] || { red "not cloned"; continue; }
    if printf '%s' "$DATA_REPOS" | grep -q "$entry"; then
      git -C "$ROOT/$path" pull --rebase --autostash || red "pull failed"
    else
      git -C "$ROOT/$path" pull --ff-only || red "pull failed (local changes or diverged branch)"
    fi
  done
}

cmd_push() {
  for entry in $DATA_REPOS; do
    local path
    path="$(field "$entry" 1)"
    title "$path"
    [ -d "$ROOT/$path/.git" ] || { red "not cloned"; continue; }
    if is_dirty "$ROOT/$path"; then
      git -C "$ROOT/$path" add -A
      git -C "$ROOT/$path" commit -q -m "sync $HOST $(date '+%Y-%m-%d %H:%M')"
    fi
    if git -C "$ROOT/$path" rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
      git -C "$ROOT/$path" pull --rebase -q && git -C "$ROOT/$path" push -q && green "pushed" || red "push failed"
    else
      git -C "$ROOT/$path" push -q -u origin "$(current_branch "$ROOT/$path")" && green "pushed (upstream set)" || red "push failed"
    fi
  done
  for entry in $CODE_REPOS; do
    local path protected branch
    path="$(field "$entry" 1)"; protected="$(field "$entry" 4)"
    title "$path"
    [ -d "$ROOT/$path/.git" ] || { red "not cloned"; continue; }
    branch="$(current_branch "$ROOT/$path")"
    is_dirty "$ROOT/$path" && red "uncommitted changes (not pushed, commit them first)"
    if [ "$branch" = "$protected" ]; then
      red "on $branch (production): skipped"
      continue
    fi
    git -C "$ROOT/$path" push -q origin "$branch" && green "pushed $branch" || red "push failed"
  done
}

cmd_status() {
  for entry in $DATA_REPOS $CODE_REPOS; do
    local path
    path="$(field "$entry" 1)"
    [ -d "$ROOT/$path/.git" ] || { red "$path: not cloned"; continue; }
    git -C "$ROOT/$path" fetch -q
    printf '%-30s %s\n' "$path" "$(git -C "$ROOT/$path" status -sb | head -1)"
    is_dirty "$ROOT/$path" && red "  uncommitted changes"
  done
}

case "${1:-}" in
  setup) cmd_setup ;;
  pull) cmd_pull ;;
  push) cmd_push ;;
  status) cmd_status ;;
  *) echo "usage: $0 setup|pull|push|status"; exit 1 ;;
esac
