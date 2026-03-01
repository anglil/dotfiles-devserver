#!/bin/bash
SESSION="claude-$(hostname -s)"
EDEN_AGENTS="1 2 3 4"
ALL_AGENTS="1 2 3 4 5"

# Re-mount Eden for all Eden-backed agents (runs every connect)
for i in $EDEN_AGENTS; do
  if [ -d "$HOME/agent$i/fbsource" ]; then
    echo "Fixing Eden redirections for agent$i..."
    (cd "$HOME/agent$i/fbsource" && edenfsctl redirect fixup) 2>/dev/null || true
  fi
done

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
