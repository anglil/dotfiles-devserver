#!/bin/bash
# Deploy dotfiles to a devserver without needing GitHub access
# Usage: ./deploy-direct.sh <hostname>

SERVER="${1:?Usage: $0 <hostname>}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Deploying to $SERVER (tap YubiKey when prompted) ==="
x2ssh "$SERVER" -- bash -s <<'REMOTE_SCRIPT'
mkdir -p ~/agent{1,2,3,4,5}
cat > ~/start-agents.sh <<'STARTSCRIPT'
#!/bin/bash
SESSION="claude-$(hostname -s)"
EDEN_AGENTS="1 2 3 4"
ALL_AGENTS="1 2 3 4 5"

# Re-mount Eden for all Eden-backed agents (runs every connect, with timeout)
for i in $EDEN_AGENTS; do
  if [ -d "$HOME/agent$i/fbsource" ]; then
    timeout 5 bash -c "cd '$HOME/agent$i/fbsource' && edenfsctl redirect fixup" 2>/dev/null || true
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
STARTSCRIPT
chmod +x ~/start-agents.sh

cat > ~/.tmux.conf <<'TMUXCONF'
set -g default-command "${SHELL}"
set -g history-limit 500000
set -g status-right "#{s/.facebook.com//:host} • %Y-%m-%d %H:%M"
set -s default-terminal "tmux-256color"
set -s escape-time 0

# Preserve window names set by start-agents.sh (agent1, agent2, etc.)
set -g automatic-rename off
set -g allow-rename off

# Mouse support for scrolling
set -g mouse on

# Enable OSC 52 clipboard
set -g set-clipboard on

# Session resilience
set -g display-time 4000
set -g focus-events on
TMUXCONF

tmux kill-server 2>/dev/null || true
echo "=== DEPLOYED on $(hostname -s) ==="
REMOTE_SCRIPT
