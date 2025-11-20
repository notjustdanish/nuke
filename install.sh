
#!/bin/bash
set -e

echo -e "\033[1;31m╔═══════════════════════════════════════════╗"
echo -e "     Installing nuke Baby..😘 — unfiltered Kali AI co-pilot"
echo -e "╚═══════════════════════════════════════════╝\033[0m"

# === Detect RAM & pick perfect model ===
RAM_GB=$(free -m | awk '/^Mem:/{printf "%d", $2/1024}')
case $RAM_GB in
    [1-5])   MODEL="phi3:mini" ; RAM_MSG="4–5 GB" ;;
    [6-9])   MODEL="qwen2.5:7b-instruct-q5_K_M" ; RAM_MSG="6–9 GB" ;;
    1[0-3])  MODEL="qwen2.5:14b-instruct-q5_K_M" ; RAM_MSG="10–13 GB" ;;
    *)       MODEL="qwen2.5:32b-instruct-q5_K_M" ; RAM_MSG="14+ GB (beast)" ;;
esac

echo -e "\033[33mDetected $RAM_GB GB RAM → using $MODEL ($RAM_MSG)\033[0m"

# === Install Ollama ===
echo -e "\033[33mInstalling Ollama...\033[0m"
curl -fsSL https://ollama.com/install.sh | sh

# === CRITICAL FIX: Start Ollama server properly and wait ===
echo -e "\033[33mStarting Ollama server...\033[0m"
ollama serve &>/dev/null &
OLLAMA_PID=$!
sleep 6   # give it time to fully start (this is the real fix)

# === Download model (with retry) ===
echo -e "\033[33mDownloading $MODEL — this may take a while...\033[0m"
for i in {1..3}; do
    if ollama pull "$MODEL"; then
        break
    else
        echo "Retry $i/3 in 5s..."
        sleep 5
    fi
done

# === Install tiny dependencies ===
echo -e "\033[33mInstalling xclip + fzf...\033[0m"
sudo apt update -qq && sudo apt install -y xclip fzf

# === Install nuke binary ===
echo -e "\033[33mInstalling nuke command...\033[0m"
mkdir -p ~/bin
curl -fsSL https://raw.githubusercontent.com/notjustdanish/nuke/main/src/nuke -o ~/bin/nuke
chmod +x ~/bin/nuke

# === Add to PATH forever ===
if ! grep -q "nuke" ~/.bashrc 2>/dev/null; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
    echo "alias nuke='~/bin/nuke'" >> ~/.bashrc
fi

# === Final success ===
source ~/.bashrc 2>/dev/null || true

echo -e "\n\033[1;32m╔═══════════════════════════════════════════╗"
echo -e "   nuke INSTALLED SUCCESSFULLY!"
echo -e "   Model: $MODEL"
echo -e "   Just type: nuke"
echo -e "╚═══════════════════════════════════════════╝\033[0m"
echo -e "\033[90mMade with pure rage by wtf.mr\033[0m"
