#!/usr/bin/env sh
set -eu

SOURCE="${1:-https://github.com/sc543753481/codex-subagents-dispatcher.git}"
REF="${REF:-}"
DRY_RUN="${DRY_RUN:-0}"
AUTHORIZE="${AUTHORIZE:-0}"
MARKETPLACE_NAME="codex-subagents-dispatcher"
PLUGIN_NAME="subagent-dispatcher"
AUTHORIZATION_TEXT="When a task can be split into independent workstreams, prefer the subagent-dispatcher workflow and use up to 5 subagents by default, up to 8 for read-only research. Before spawning subagents, briefly state the split, whether each agent is read-only or may edit files, and how results will be synthesized."

if [ "$DRY_RUN" != "1" ] && ! command -v codex >/dev/null 2>&1; then
  echo "Codex CLI was not found on PATH. Install and sign in to Codex, then run this installer again." >&2
  exit 1
fi

run_codex() {
  if [ "$DRY_RUN" = "1" ]; then
    printf 'codex'
    for arg do
      printf ' %s' "$arg"
    done
    printf '\n'
  else
    codex "$@"
  fi
}

if [ "$DRY_RUN" != "1" ] && codex plugin marketplace list 2>/dev/null | grep -E "^${MARKETPLACE_NAME}[[:space:]]" >/dev/null 2>&1; then
  echo "Marketplace already configured: $MARKETPLACE_NAME"
else
  echo "Adding Codex plugin marketplace: $SOURCE"
  if [ -n "$REF" ]; then
    run_codex plugin marketplace add "$SOURCE" --ref "$REF"
  else
    run_codex plugin marketplace add "$SOURCE"
  fi
fi

PLUGIN_SELECTOR="$PLUGIN_NAME@$MARKETPLACE_NAME"
if [ "$DRY_RUN" != "1" ] && codex plugin list 2>/dev/null | grep -E "^${PLUGIN_SELECTOR}[[:space:]]+installed" >/dev/null 2>&1; then
  echo "Plugin already installed: $PLUGIN_SELECTOR"
else
  echo "Installing $PLUGIN_NAME from $MARKETPLACE_NAME"
  run_codex plugin add "$PLUGIN_SELECTOR"
fi

if [ "$AUTHORIZE" = "1" ] || [ "${SUBAGENT_DISPATCHER_AUTHORIZE:-0}" = "1" ]; then
  CODEX_HOME_DIR="${CODEX_HOME:-"$HOME/.codex"}"
  AGENTS_PATH="$CODEX_HOME_DIR/AGENTS.md"
  if [ "$DRY_RUN" = "1" ]; then
    echo "Would ensure authorization in $AGENTS_PATH"
  else
    mkdir -p "$CODEX_HOME_DIR"
    if [ -f "$AGENTS_PATH" ] && grep -F "subagent-dispatcher workflow" "$AGENTS_PATH" >/dev/null 2>&1; then
      echo "AGENTS.md authorization already present: $AGENTS_PATH"
    else
      if [ -s "$AGENTS_PATH" ]; then
        printf '\n\n' >>"$AGENTS_PATH"
      fi
      printf '%s\n\n%s\n' "# subagent-dispatcher" "$AUTHORIZATION_TEXT" >>"$AGENTS_PATH"
      echo "Added AGENTS.md authorization: $AGENTS_PATH"
    fi
  fi
fi

echo
echo "Ready: $PLUGIN_NAME."
echo "Open a new Codex thread, then ask Codex to use subagent-dispatcher."
