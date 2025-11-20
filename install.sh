#!/bin/bash
set -e

echo -e "/033[1;31m @wtf.mr\033[0m"

echo -e "\033[1;31m╔═══════════════════════════════════════════╗"
echo -e "                        Installing nuke —"
echo -e "          ╚═══════════════════════════════════════════╝\033[0m"
echo -e "/033[1;31m unfiltered Kali AI co-pilot\033[0m"

# === 1. Fix PATH forever (works in every shell, every session) ===
mkdir -p ~/bin
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.profile 2>/dev/null || true
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true
source ~/.bashrc 2>/dev/null || true

# === 2. Install Ollama ===
curl -fsSL https://ollama.com/install.sh | sh

# === 3. Smart model picker + auto-upgrade broken models ===
RAM_GB=$(free -m | awk '/^Mem:/{printf "%d", $2/1024}')
case $RAM_GB in
    [1-2]) MODEL="qwen2.5:3b-instruct-q8_0" ;;
    [3-9]) MODEL="qwen2.5:7b-instruct-q5_K_M" ;;
    1[0-3]) MODEL="qwen2.5:14b-instruct-q5_K_M" ;;
    *) MODEL="qwen2.5:32b-instruct-q5_K_M" ;;
esac

# Start server
ollama serve &>/dev/null &
sleep 6

# Remove trash models if exist
ollama rm phi3:mini 2>/dev/null || true
ollama rm gemma2:2b 2>/dev/null || true

# Pull the correct one
echo -e "\033[33mPulling $MODEL (perfect for ${RAM_GB}GB RAM)...\033[0m"
ollama pull "$MODEL"

# === 4. Install nuke script with correct model baked in ===
cat > ~/bin/nuke << 'EOF'
#!/bin/bash
# nuke by wtf.mr — auto-fixes model on first run
RAM_GB=$(free -m | awk '/^Mem:/{printf "%d", $2/1024}')
case $RAM_GB in
    [1-2]) M="qwen2.5:3b-instruct-q8_0" ;;
    [3-9]) M="qwen2.5:7b-instruct-q5_K_M" ;;
    1[0-3]) M="qwen2.5:14b-instruct-q5_K_M" ;;
    *) M="qwen2.5:32b-instruct-q5_K_M" ;;
esac

# Auto-upgrade if wrong model
CURRENT=$(ollama list 2>/dev/null | awk 'NR==2{print $1}' | cut -d: -f1)
if [[ "$CURRENT" == "phi3" ]] || [[ -z "$CURRENT" ]]; then
    echo -e "\033[31mUpgrading to $M...\033[0m"
    ollama pull "$M"
fi

#real nuke loop (keep your original code, just use $M)
clear
echo -e "\033[31m"
cat << "ASCII"
███╗   ██╗██╗   ██╗██╗  ██╗███████╗
████╗  ██║██║   ██║██║ ██╔╝██╔════╝
██╔██╗ ██║██║   ██║█████╔╝ █████╗  
██║╚██╗██║██║   ██║██╔═██╗ ██╔══╝  
██║ ╚████║╚██████╔╝██║  ██╗███████╗
╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
           press r → it runs
ASCII
echo -e "\033[0m"

while :; do
    read -p "▸ " input
    [[ "$input" == "q" ]] && break
    response=$(ollama run "$M" "$input" 2>/dev/null)
    echo "$response"
    read -n1 -p "[r] Run • [SPACE] Details • [ENTER] Copy • mā[q] Quit " key
    if [[ $key == "r" ]]; then
        echo "$response" | grep -E '^([a-z0-9]|sudo|nmap|nc|python|bash)' | bash 2>/dev/null || true
        echo "Finished. Press any key..."
        read -n1
    fi
    clear
done
EOF
chmod +x ~/bin/nuke

# === FINAL ===
echo -e "\n\033[1;32m╔═══════════════════════════════════════════╗"
echo -e "   nuke READY — just type: nuke"
echo -e "   Model: $MODEL (${RAM_GB}GB detected)"
echo -e "╚═══════════════════════════════════════════╝\033[0m"
echo -e "/033[1;31m @wtf.mr\033[0m"
