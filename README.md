# cc-notify

KDE Desktop notifications for Claude Code (CC). Uses CC hooks to fire desktop
notifications with a bit of additional context when user input is neeeded.

_I have only tested this with my own personal tool stack (Kitty + Tmux) on KDE
43 Plasma DE. I imagine it would be easy to extend, though._

I tend to have multiple CC instances running in different tmux windows all in
different git worktrees in a project. I like having the additional context
beyond what term notifications can provide, so desktop notifications seemed like
a good option.

## What fires

| Event                      | Notification                          | Urgency  |
| -------------------------- | ------------------------------------- | -------- |
| Permission prompt          | `🔐 Permission Required [my-project]` | Critical |
| Idle / waiting             | `💤 Claude Idle [my-project]`         | Normal   |
| Question (AskUserQuestion) | `❓ Question [my-project]`            | Normal   |
| Task finished              | `✅ Claude Finished [my-project]`     | Normal   |

## Requirements

- Linux with `notify-send` (libnotify) — standard on KDE, GNOME, and most desktop environments
- `jq`

## Installation

### Global (recommended)

Install once in `~/.claude/` and every Claude Code session gets notifications automatically.

1. Copy the hook script:

```bash
mkdir -p ~/.claude/hooks
cp cc-notify.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/cc-notify.sh
```

2. Merge the hooks config into `~/.claude/settings.json`. Add the `"Notification"` and `"Stop"` entries alongside any existing keys:

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "permission_prompt|idle_prompt|elicitation_dialog",
        "hooks": [
          {
            "type": "command",
            "command": "\"$HOME\"/.claude/hooks/cc-notify.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$HOME\"/.claude/hooks/cc-notify.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

### Per-project

If you prefer to scope notifications to a single project:

1. Copy the hook script:

```bash
mkdir -p your-project/.claude/hooks
cp cc-notify.sh your-project/.claude/hooks/
chmod +x your-project/.claude/hooks/cc-notify.sh
```

2. Merge the hooks config into your project's `.claude/settings.json`, using `$CLAUDE_PROJECT_DIR` instead of `$HOME`:

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "permission_prompt|idle_prompt|elicitation_dialog",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/cc-notify.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/cc-notify.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

### Git worktrees

The script uses `basename "$CWD"` for the notification label, so each worktree gets a distinct tag automatically (e.g., `[my-project-wt1]`, `[my-project-wt2]`). With the global install, worktrees just work. With per-project install, commit `.claude/hooks/cc-notify.sh` and `.claude/settings.json` so all worktrees share them.
