# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

cc-notify is a Claude Code hooks integration that sends KDE desktop notifications via `notify-send`. It notifies the user when Claude Code needs attention (permission prompts, idle prompts), finishes a task, or encounters a tool failure.

## Installation

Copy into a project's `.claude/` directory:
- `cc-notify.sh` → `.claude/hooks/cc-notify.sh` (must be executable)
- `settings.json` → merge hooks config into `.claude/settings.json`

## Architecture

**`cc-notify.sh`** — Single bash script that acts as the hook handler. Reads JSON from stdin (Claude Code hook protocol), extracts the event type and fields with `jq`, then dispatches to `notify-send` with appropriate urgency levels and icons.

Hook events handled:
- `Notification` (subtypes: `permission_prompt` at critical urgency, `idle_prompt` at normal)
- `Stop` — task completion
- `PostToolUseFailure` — tool errors

**`settings.json`** — Claude Code hooks configuration that wires the three events to the script. Uses `$CLAUDE_PROJECT_DIR` to resolve the script path. The `Notification` hook uses a matcher to filter for `permission_prompt|idle_prompt` only.

## Dependencies

- `jq` — JSON parsing from hook stdin
- `notify-send` — desktop notifications (libnotify, standard on KDE/GNOME Linux)
- Bash 4+
