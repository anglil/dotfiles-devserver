#!/bin/bash
SESSION="claude-$(hostname -s)"
EDEN_AGENTS="1 2 3 4"  # These have fbsource Eden mounts
ALL_AGENTS="1 2 3 4 5" # All Claude sessions

# Health check function - runs eden doctor and verifies mounts
check_eden_health() {
  echo "=== Checking Eden health ==="
  eden doctor 2>&1
  for i in $EDEN_AGENTS; do
    if [[ -L ~/agent$i/README_EDEN.txt ]]; then
      echo "WARNING: agent$i not mounted, running eden restart..."
      eden restart --full
      sleep 10
      break
    fi
  done
  echo "=== Eden health check complete ==="
}

# Function to sync repo before starting claude (only for Eden repos)
sync_repo() {
  dir=$1
  echo "=== Syncing $dir ==="
  cd $dir || return
  sl pull 2>/dev/null && sl smartlog 2>/dev/null
  if [[ $(sl status) != "" ]]; then
    echo "Merge conflicts detected in $dir, attempting auto-resolve..."
    sl resolve --all --tool :merge-other 2>/dev/null || true
  fi
  sl rebase -d stable 2>/dev/null || true
  echo "=== $dir ready ==="
}

# Main execution
if ! tmux has-session -t $SESSION 2>/dev/null; then
  check_eden_health
  
  echo "Syncing Eden agent repos..."
  for i in $EDEN_AGENTS; do
    (sync_repo ~/agent$i) &
  done
  wait
  echo "All Eden repos synced!"

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
