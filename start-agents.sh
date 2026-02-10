#!/bin/bash
SESSION="claude-$(hostname -s)"
EDEN_AGENTS="1 2 3 4"  # These have fbsource Eden mounts
ALL_AGENTS="1 2 3 4 5" # All Claude sessions

# Create new session only if it doesn't exist
if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  # Create tmux session with first window
  tmux new-session -d -s "$SESSION" -n agent1
  tmux send-keys -t "$SESSION":agent1 'cd ~/agent1 && claude --dangerously-skip-permissions' Enter

  # Create windows for all other agents (2-5)
  for i in 2 3 4 5; do
    tmux new-window -t "$SESSION" -n "agent$i"
    tmux send-keys -t "$SESSION":"agent$i" "cd ~/agent$i && claude --dangerously-skip-permissions" Enter
  done

  tmux select-window -t "$SESSION":agent1
fi

tmux -CC attach -t "$SESSION"
