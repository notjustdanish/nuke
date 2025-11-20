#!/bin/bash
set -e

echo -e "\033[1;31mInstalling nuke Baby😘 — unfiltered Kali AI co-pilot by wtf.mr\033[0m"

# === SMART MODEL SELECTOR BASED ON RAM ===
detect_ram() {
    free -m | awk '/^Mem:/{print int($2/1024)}'
}

get_model() {
    RAM_GB=$(detect_ram)
    echo "Detected ${RAM_GB}GB RAM → selecting best model..." >&2
    case $RAM_GB in
        [1-5])   echo "phi3:mini"                    ;;  # 4–5 GB  → ~3GB RAM usage
        [6-9])   echo "qwen2.5:7b-instruct-q5_K_M"   ;;  # 6–9 GB  → ~6GB
        1[0-3])  echo "qwen2.5:14b-instruct-q5_K_M"  ;;  # 10–13 GB → ~10GB
        *)       echo "qwen2.5:32b-instruct-q5_K_M"  ;;  # 14+ GB → beast mode
    esac
}

# Allow manual override: MODEL=phi3 curl ... | bash
MODEL="${MODEL:-$(get_model)}"

# === INSTALL OLLAMA ===
echo -e "\033[33mInstalling Ollama...\033[0m"
curl -fsSL https://ollama.com/install.sh | sh

# === PULL BEST MODEL FOR YOUR MACHINE ===
echo -e "\033[33mDownloading $MODEL (optimized for your RAM)...\033[0m"
ollama pull "$MODEL"

# === INSTALL TINY DEPENDENCIES ===
echo -e "\033[33mInstalling xclip + fzf...\033[0m"
sudo apt update && sudo apt install -y xclip fzf

# === INSTALL nuke SCRIPT ===
echo -e "\033[33mPlacing nuke in ~/bin...\033[0m"
mkdir -p ~/bin
curl -sSL https://raw.githubusercontent.com/notjustdanish/nuke/main/src/nuke -o ~/bin/nuke
chmod +x ~/bin/nuke

# === ADD ALIAS (supports bash, zsh, fish) ===
SHELLRC=""
if [ -n "$ZSH_VERSION" ]; then
    SHELLRC="$HOME/.zshrc"
elif [ -n "$FISH_VERSION" ]; then
    mkdir -p ~/.config/fish
    SHELLRC="$HOME/.config/fish/config.fish"
    echo "alias nuke '~/bin/nuke'" >> "$SHELLRC"
else
    SHELLRC="$HOME/.bashrc"
fi

if [ -n "$SHELLRC" ] && ! grep -q "nuke" "$SHELLRC" 2>/dev/null; then
    echo "alias nuke='~/bin/nuke'" >> "$SHELLRC"
fi

# === DONE ===
echo -e "\n\033[1;32mNUKE INSTALLED SUCCESSFULLY!\033[0m"
echo -e "\033[1;36mModel: $MODEL (perfect for your ${RAM_GB}GB RAM)\033[0m"
echo -e "\033[1;36mJust type → nuke\033[0m"
echo -e "\033[90mMade by wtf.mr..⚙️\033[0m"
