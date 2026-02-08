# Devserver Dotfiles for Claude Code

Configuration files for running 5 Claude Code agents in tmux on a Meta devserver.

## Quick Setup

### On your Mac (local machine)

1. Add to your `~/.zshrc`:
   ```bash
   alias devserver1="x2ssh -et YOUR_DEVSERVER.cco0.facebook.com -c '~/start-agents.sh'"
   ```

2. Install iTerm2 (recommended):
   ```bash
   brew install --cask iterm2
   ```

3. Configure iTerm2 for tabs (not windows):
   ```bash
   defaults write com.googlecode.iterm2 OpenTmuxWindowsIn -int 2
   ```

### On your Devserver

1. Copy config files:
   ```bash
   cp .tmux.conf ~/.tmux.conf
   cp start-agents.sh ~/start-agents.sh
   chmod +x ~/start-agents.sh
   ```

2. Create agent directories (if using Eden):
   ```bash
   mkdir -p ~/agent{1,2,3,4,5}
   # Set up Eden mounts for agent1-3 as needed
   ```

3. Start GClaude daemon (for gchat integration):
   ```bash
   nohup gclaude > ~/.gclaude.log 2>&1 &
   ```

## Usage

- **Connect:** Run `devserver1` in iTerm2
- **Switch agents:** Click tabs or ⌘+1 through ⌘+5
- **Detach:** Close window or Ctrl+b, d
- **Reattach:** Run `devserver1` again
- **Copy text:** Select with mouse (auto-copies) or hold Shift + select
- **Scroll:** Mouse wheel or Ctrl+b, [ for scroll mode

## Files

| File | Description |
|------|-------------|
| `.tmux.conf` | Tmux configuration (copy to ~/.tmux.conf on devserver) |
| `start-agents.sh` | Agent startup script (copy to ~/ on devserver) |
| `.zshrc_devserver` | Zshrc additions (for local Mac) |
