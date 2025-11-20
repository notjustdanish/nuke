#!/bin/bash
set -e

echo -e "\033[1;31m
   _   __      __      __
  / | / /_  __/ /_____/_/
 /  |/ / / / / //_/ _/_/
/_/|_/ /___/ /_/  /___/
           nuke by wtf.mr ☢️
\033[0m"

# Fix PATH forever
mkdir -p ~/bin
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.profile 2>/dev/null || true
source ~/.bashrc 2>/dev/null || true

# Install Ollama
echo -e "\033[33mInstalling Ollama...\033[0m"
curl -fsSL https://ollama.com/install.sh | sh

# Smart model selection based on RAM
RAM=$(free -m | awk '/^Mem:/{print int($2/1024)}')
case $RAM in
    [1-4]) MODEL="qwen2.5:3b-instruct-q8_0" ;;
    [5-9]) MODEL="qwen2.5:7b-instruct-q5_K_M" ;;
    1[0-9]|2[0-9]|3[0-9]) MODEL="qwen2.5:14b-instruct-q5_K_M" ;;
    *) MODEL="qwen2.5:32b-instruct-q5_K_M" ;;
esac

echo -e "\033[33mDetected ${RAM}GB RAM → pulling $MODEL\033[0m"
ollama pull "$MODEL"

# Install final nuke script
cat > ~/bin/nuke << 'EOF'
#!/bin/bash
# nuke — final version by wtf.mr
pgrep -f "ollama serve" > /dev/null || ollama serve > /dev/null 2>&1 &
sleep 2

RAM=$(free -m | awk '/^Mem:/{print int($2/1024)}')
case $RAM in
    [1-4]) M="qwen2.5:3b-instruct-q8_0" ;;
    [5-9]) M="qwen2.5:7b-instruct-q5_K_M" ;;
    1[0-9]|2[0-9]|3[0-9]) M="qwen2.5:14b-instruct-q5_K_M" ;;
    *) M="qwen2.5:32b-instruct-q5_K_M" ;;
esac

# Use existing model if available
if ollama list | grep -q "$M"; then
    MODEL="$M"
else
    MODEL=$(ollama list | awk 'NR==2{print $1}')
fi

clear
echo -e "\033[1;31m
   _   __      __      __
  / | / /_  __/ /_____/_/
 /  |/ / / / / //_/ _/_/
/_/|_/ /___/ /_/  /___/
           press r → it runs
\033[0m"

while :; do
    read -p "▸ " q
    [[ "$q" =~ ^[qQ]$ ]] && { clear; echo -e "\033[31mStay dangerous, wtf.mr ☢️\033[0m"; exit 0; }

    echo -e "\033[90mthinking...\033[0m"
    resp=$(ollama run "$MODEL" "$q" 2>/dev/null | tail -n 30)
    [[ -z "$resp" ]] && { echo -e "\033[31mno response — try again\033[0m"; continue; }

    echo -e "\033[32m$resp\033[0m"
    read -n1 -p $'\033[1;33m[r] Run • [ENTER] Copy • [q] Quit → \033[0m' k; echo

    case "$k" in
        r|R) echo -e "\033[31mExecuting...\033[0m"; echo "$resp" | bash 2>/dev/null || echo -e "\033[31mfailed\033[0m"; read -n1 ;;
        "")  echo "$resp" | xclip -selection clipboard 2>/dev/null && echo -e "\033[32mCopied!\033[0m"; sleep 1 ;;
    esac
    clear
    echo -e "\033[1;31mNUKE — $MODEL • ${RAM}GB RAM\033[0m"
done
EOF

chmod +x ~/bin/nuke

echo -e "\033[1;32m
╔══════════════════════════════════════════╗
║           nuke INSTALLED!                ║
║           Then type: nuke                ║
╚══════════════════════════════════════════╝
\033[0m"
