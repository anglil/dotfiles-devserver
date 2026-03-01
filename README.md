# Devserver Dotfiles for Claude Code

Configuration files for running 5 Claude Code agents in tmux across 3 devservers.

## Quick Setup

### On your Mac (local machine)

1. Add to your `~/.zshrc` (or source `.zshrc_devserver`):
   ```bash
   alias devserver1="x2ssh devvm46739.lla0.facebook.com -t '~/start-agents.sh'"
   alias devserver2="x2ssh devvm30302.nha0.facebook.com -t '~/start-agents.sh'"
   alias devserver3="x2ssh devvm46759.lla0.facebook.com -t '~/start-agents.sh'"
   ```

2. Install iTerm2 (recommended):
   ```bash
   brew install --cask iterm2
   ```

3. Configure iTerm2 for tabs (not windows):
   ```bash
   defaults write com.googlecode.iterm2 OpenTmuxWindowsIn -int 2
   ```

### On each Devserver

1. Copy config files:
   ```bash
   cp .tmux.conf ~/.tmux.conf
   cp start-agents.sh ~/start-agents.sh
   chmod +x ~/start-agents.sh
   ```

2. Create agent directories (if using Eden):
   ```bash
   mkdir -p ~/agent{1,2,3,4,5}
   # Set up Eden mounts for agent1-4 as needed
   ```

3. Start GClaude daemon (for gchat integration):
   ```bash
   nohup gclaude > ~/.gclaude.log 2>&1 &
   ```

## Usage

- **Connect:** Run `devserver1` / `devserver2` / `devserver3` in iTerm2
- **Switch agents:** Click tabs or ⌘+1 through ⌘+5
- **Tab names:** Tabs are named `agent1`–`agent5` and preserved across reconnects
- **Eden re-mount:** Expired Eden mounts are automatically fixed on every connect
- **Detach:** Close window or Ctrl+b, d
- **Reattach:** Run `devserverN` again — tabs and Eden mounts are restored
- **Copy text:** Select with mouse (auto-copies) or hold Shift + select
- **Scroll:** Mouse wheel or Ctrl+b, [ for scroll mode

## Files

| File | Description |
|------|-------------|
| `.tmux.conf` | Tmux configuration — preserves agent tab names (copy to ~/.tmux.conf) |
| `start-agents.sh` | Agent startup script with Eden re-mount (copy to ~/) |
| `.zshrc_devserver` | Zshrc aliases for all 3 devservers (for local Mac) |
