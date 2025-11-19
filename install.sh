#!/bin/bash
set -e

echo -e "\033[1;31mInstalling nuke by wtf.mr – optimized for 8–16 GB laptops\033[0m"

# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Pull the perfect model for 8–16 GB
echo -e "\033[33mDownloading qwen2.5:14b (best for 8–16 GB RAM)…\033[0m"
ollama pull qwen2.5:14b-instruct-q5_K_M

# Install tiny dependencies
sudo apt update && sudo apt install -y fzf xclip

# Install nuke script
mkdir -p ~/bin
curl -sSL https://raw.githubusercontent.com/yourusername/nuke/main/src/nuke -o ~/bin/nuke
chmod +x ~/bin/nuke

# Add alias
SHELLRC="$HOME/.$(basename "$SHELL"rc)"
grep -q "nuke" "$SHELLRC" 2>/dev/null || echo "alias nuke='~/bin/nuke'" >> "$SHELLRC"

echo -e "\n\033[1;32mNUKE INSTALLED SUCCESSFULLY!\033[0m"
echo -e "\033[1;36mJust type: nuke\033[0m"
echo -e "\033[90mMade with love by wtf.mr\033[0m"