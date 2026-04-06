#!/usr/bin/env bash
# platform-detect.sh -- Detects the current platform (WSL 2, macOS, or native Linux).
# Sourced by all other scripts. Sets PLATFORM, IS_WSL, IS_MACOS, SHELL_RC, NOTIFY_CMD.
#
# Usage: source "$(dirname "$0")/../scripts/platform-detect.sh"
#        Or from scripts/: source "$(dirname "$0")/platform-detect.sh"
#
# Uses save/restore pattern for shell options so strict mode does not leak to callers.

# Save current shell options so we can restore them when done.
# This prevents strict mode (set -euo pipefail) from leaking to the sourcing script.
_pd_old_opts=$(set +o)

set -euo pipefail

# Platform detection
PLATFORM="unknown"
IS_WSL=false
IS_MACOS=false
HOME_DIR="${HOME:-/home/$(whoami)}"

if [[ -f /proc/version ]] && grep -qi microsoft /proc/version 2>/dev/null; then
  PLATFORM="wsl2"
  IS_WSL=true
elif [[ "$(uname -s)" == "Darwin" ]]; then
  PLATFORM="macos"
  IS_MACOS=true
elif [[ "$(uname -s)" == "Linux" ]]; then
  PLATFORM="linux"
else
  echo "ERROR: Unsupported platform: $(uname -s)"
  echo "This guide supports WSL 2 (Ubuntu), macOS, and native Linux."
  # Restore shell options before exiting
  eval "$_pd_old_opts"
  return 1 2>/dev/null || exit 1
fi

# Shell RC file detection
if [[ -f "$HOME_DIR/.zshrc" ]]; then
  SHELL_RC="$HOME_DIR/.zshrc"
elif [[ -f "$HOME_DIR/.bashrc" ]]; then
  SHELL_RC="$HOME_DIR/.bashrc"
else
  SHELL_RC="$HOME_DIR/.bashrc"
fi

# Notification command
if $IS_WSL; then
  NOTIFY_CMD="wsl-notify-send.exe"
elif $IS_MACOS; then
  NOTIFY_CMD="osascript -e"
else
  NOTIFY_CMD="notify-send"
fi

# Export all variables
export PLATFORM IS_WSL IS_MACOS HOME_DIR SHELL_RC NOTIFY_CMD

# Restore the caller's shell options
eval "$_pd_old_opts"
unset _pd_old_opts
