#!/bin/bash
SESSION="claude-$(hostname -s)"
EDEN_AGENTS="1 2 3 4"  # These have fbsource Eden mounts
ALL_AGENTS="1 2 3 4 5" # All Claude sessions
SYNC_TIMEOUT=30        # Max seconds per repo sync

# Main execution
if ! tmux has-session -t $SESSION 2>/dev/null; then
  # Quick Eden health check (skip if eden not available)
  if command -v eden &>/dev/null; then
    echo "=== Quick Eden check ==="
    eden doctor 2>&1 || true
  fi

  # Sync repos with timeout (non-blocking - agents start even if sync fails)
  echo "Syncing Eden agent repos (${SYNC_TIMEOUT}s timeout per repo)..."
  for i in $EDEN_AGENTS; do
    ( timeout $SYNC_TIMEOUT bash -c "
      cd ~/agent$i 2>/dev/null || exit 0
      sl pull 2>/dev/null
      sl rebase -d stable 2>/dev/null || true
      echo \"=== agent$i synced ===\"
    " || echo "=== agent$i sync skipped (timeout) ===" ) &
  done
  wait
  echo "Sync complete!"

  # Create tmux session with first window
  tmux new-session -d -s $SESSION -n agent1
  tmux send-keys -t $SESSION:agent1 'cd ~/agent1 && claude --dangerously-skip-permissions' Enter

  # Create windows for all other agents (2-5)
  for i in 2 3 4 5; do
    tmux new-window -t $SESSION -n "agent$i"
    tmux send-keys -t $SESSION:"agent$i" "cd ~/agent$i && claude --dangerously-skip-permissions" Enter
  done

  tmux select-window -t $SESSION:agent1
fi

tmux -CC attach -t $SESSION
