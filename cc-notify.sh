#!/usr/bin/env bash
# cc-notify.sh — Desktop notification hook for Claude Code
# Place in .claude/hooks/ and configure in .claude/settings.json
#
# Reads hook JSON from stdin, sends a KDE desktop notification.

INPUT=$(cat)

# Skip notification if the tmux window running this session is currently active
if [ -n "$TMUX" ]; then
  # Get the active window and pane in the current tmux session
  active_pane=$(tmux display-message -p '#{pane_id}' 2>/dev/null)
  # Find which pane owns this process by walking up the process tree
  pid=$$
  my_pane=""
  while [ "$pid" -gt 1 ] 2>/dev/null; do
    my_pane=$(tmux list-panes -a -F '#{pane_id} #{pane_pid}' 2>/dev/null | awk -v p="$pid" '$2 == p {print $1; exit}')
    [ -n "$my_pane" ] && break
    pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
  done
  if [ -n "$my_pane" ]; then
    # Check if that pane's window is the active one in its session
    is_active=$(tmux display-message -t "$my_pane" -p '#{window_active}' 2>/dev/null)
    [ "$is_active" = "1" ] && exit 0
  fi
fi

EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // "unknown"')

# Identify which worktree/window this is from
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')
LABEL=$(basename "$CWD")

case "$EVENT" in
Notification)
  TYPE=$(echo "$INPUT" | jq -r '.notification_type // ""')
  MSG=$(echo "$INPUT" | jq -r '.message // "Needs attention"')
  TITLE=$(echo "$INPUT" | jq -r '.title // "Claude Code"')

  case "$TYPE" in
  permission_prompt)
    notify-send -u critical -a "Claude Code" -i dialog-password \
      "🔐 $TITLE [$LABEL]" "$MSG"
    ;;
  idle_prompt)
    notify-send -u normal -a "Claude Code" -i dialog-question \
      "💤 Claude Idle [$LABEL]" "$MSG"
    ;;
  elicitation_dialog)
    notify-send -u normal -a "Claude Code" -i dialog-question \
      "❓ Question [$LABEL]" "$MSG"
    ;;
  *)
    notify-send -u low -a "Claude Code" -i dialog-information \
      "Claude Code [$LABEL]" "$MSG"
    ;;
  esac
  ;;

Stop)
  notify-send -u normal -a "Claude Code" -i dialog-apply \
    "✅ Claude Finished [$LABEL]" "Ready for review"
  ;;

esac

exit 0
