#!/bin/bash
# Deploy updated dotfiles to all 3 devservers
# Run this locally — it will SSH into each devserver and update the files.

DOTFILES_DIR="$HOME/Dropbox/dotfiles-devserver"
SERVERS=(
  "devvm46739.lla0.facebook.com"
  "devvm30302.nha0.facebook.com"
  "devvm46759.lla0.facebook.com"
)

for server in "${SERVERS[@]}"; do
  echo "=== Deploying to $server ==="
  scp "$DOTFILES_DIR/.tmux.conf" "$DOTFILES_DIR/start-agents.sh" "anglil@$server:~/" && \
  x2ssh "$server" -- 'chmod +x ~/start-agents.sh && echo "Done: $(hostname -s)"'
  echo ""
done
