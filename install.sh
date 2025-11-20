#!/bin/bash
set -e

echo -e "\033[1;31mInstalling nuke — final bulletproof version\033[0m"

# Fix PATH forever
mkdir -p ~/bin
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.profile 2>/dev/null || true
source ~/.bashrc 2>/dev/null || true

# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Smart model
RAM=$(free -m | awk '/^Mem:/{print int($2/1024)}')
case $RAM in
    [1-2])   MODEL="qwen2.5:3b-instruct-q8_0" ;;
    [3-9])   MODEL="qwen2.5:7b-instruct-q5_K_M" ;;
    1[0-3])  MODEL="qwen2.5:14b-instruct-q5_K_M" ;;
    *)       MODEL="qwen2.5:32b-instruct-q5_K_M" ;;
esac

ollama pull "$MODEL"

# Install nuke script (with auto-server start)
cat > ~/bin/nuke << 'EOF'
#!/bin/bash
# Start Ollama server if not running
pgrep -f "ollama serve" > /dev/null || ollama serve > /dev/null 2>&1 &
sleep 2

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

RAM=$(free -m | awk '/^Mem:/{print int($2/1024)}')
case $RAM in
    [1-2]) M="qwen2.5:3b-instruct-q8_0" ;;
    [3-9]) M="qwen2.5:7b-instruct-q5_K_M" ;;
    1[0-3]) M="qwen2.5:14b-instruct-q5_K_M" ;;
    *) M="qwen2.5:32b-instruct-q5_K_M" ;;
esac

while :; do
    read -p "▸ " q
    [[ $q == "q" ]] && break
    echo -e "\033[90mthinking...\033[0m"
    resp=$(ollama run "$M" "$q" 2>/dev/null | tail -n 20)
    [[ -z "$resp" ]] && { echo -e "\033[31mno response — try again\033[0m"; continue; }
    echo -e "\033[32m$resp\033[0m"
    read -n1 -p $'\033[33m[r] Run • [q] Quit \033[0m' k; echo
    [[ $k == "r" ]] && echo "$resp" | bash 2>/dev/null || true
    clear
    echo -e "\033[31mNUKE — press r → it runs\033[0m"
done
EOF

chmod +x ~/bin/nuke

echo -e "\033[1;32mDONE! Close this terminal and open a new one → type: nuke\033[0m"
