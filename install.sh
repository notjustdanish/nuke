#!/bin/bash
mkdir -p ~/bin
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc

cat > ~/bin/luna << 'EOF'
#!/bin/bash
# LUNA — Your friendly Linux learning assistant ♡
CONFIG="$HOME/.luna_config"

# FIRST TIME: Ask for API key
if [[ ! -f "$CONFIG" ]]; then
    clear
    echo -e "\033[1;35m
    ╔══════════════════════════════════════════╗
    ║           Welcome to LUNA                ║
    ║   The most beautiful way to learn Linux  ║
    ╚══════════════════════════════════════════╝\033[0m\n"
    echo "Choose your AI brain:"
    echo "   1) Google Gemini → FREE & unlimited"
    echo "   2) Groq          → Super fast"
    echo "   3) OpenAI        → Reliable"
    echo
    read -p "   Select (1-3): " choice

    case $choice in
        1)
            echo -e "\nGet your FREE Gemini key here → \033[4;36mhttps://aistudio.google.com/app/apikey\033[0m\n"
            read -p "   Paste your Gemini API key: " key
            echo "PROVIDER=gemini" > "$CONFIG"
            echo "KEY=$key" >> "$CONFIG"
            echo "MODEL=gemini-1.5-flash-latest" >> "$CONFIG"
            NAME="Gemini 1.5 Flash"
            ;;
        2)
            echo -e "\nGet your FREE Groq key → \033[4;36mhttps://console.groq.com/keys\033[0m\n"
            read -p "   Paste your Groq API key: " key
            echo "PROVIDER=groq" > "$CONFIG"
            echo "KEY=$key" >> "$CONFIG"
            echo "MODEL=llama3-70b-8192" >> "$CONFIG"
            NAME="Groq Llama3-70B"
            ;;
        3)
            read -p "   Paste your OpenAI API key: " key
            echo "PROVIDER=openai" > "$CONFIG"
            echo "KEY=$key" >> "$CONFIG"
            echo "MODEL=gpt-4o-mini" >> "$CONFIG"
            NAME="GPT-4o-mini"
            ;;
        *) echo "Invalid choice"; exit 1 ;;
    esac

    echo -e "\n\033[1;32mSuccess! LUNA is ready. Type: luna\033[0m\n"
    sleep 3
fi

source "$CONFIG"

clear
echo -e "\033[1;35m
   _   __      __      __
  / | / /_  __/ /_____/_/
 /  |/ / / / / //_/ _/_/
/_/|_/ /___/ /_/  /___/
        Your Linux learning buddy ♡
\033[0m"
echo -e "Using: \033[1;33m$NAME\033[0m · type 'ex ls' to learn any command\n"

ask() {
    case $PROVIDER in
        gemini)
            curl -s "https://generativelanguage.googleapis.com/v1beta/models/$MODEL:generateContent?key=$KEY" \
                -H 'Content-Type: application/json' \
                -d "{\"contents\":[{\"role\":\"user\",\"parts\":[{\"text\":\"$1\"}]}]}" 2>/dev/null \
                | jq -r '.candidates[0].content.parts[0].text // "No response"' 2>/dev/null
            ;;
        groq)
            curl -s https://api.groq.com/openai/v1/chat/completions \
                -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" \
                -d "{\"model\":\"$MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"$1\"}],\"temperature\":0.5}" 2>/dev/null \
                | jq -r '.choices[0].message.content // "No response"' 2>/dev/null
            ;;
        openai)
            curl -s https://api.openai.com/v1/chat/completions \
                -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" \
                -d "{\"model\":\"$MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"$1\"}]}" 2>/dev/null \
                | jq -r '.choices[0].message.content // "No response"' 2>/dev/null
            ;;
    esac
}

while :; do
    printf "\033[1;36m▸ \033[0m"
    read -r input

    [[ "$input" =~ ^(q|quit)$ ]] && { clear; echo -e "\033[35mKeep learning! See you soon ♡\033[0m"; exit; }

    if [[ "$input" == ex* ]] && [[ ${#input} -gt 3 ]]; then
        cmd="${input:3}"
        echo -e "\033[90mExplaining '$cmd' in the simplest way...\033[0m"
        response=$(ask "You are a super kind and patient Linux teacher for absolute beginners. Explain the command '$cmd' using very simple words. Then give ONE safe, beginner-friendly example with a code block. Be warm and encouraging.")
        echo -e "\033[1;34m$response\033[0m"
    else
        echo -e "\033[90mThinking how to help you best...\033[0m"
        response=$(ask "You are a friendly Linux tutor for beginners. User asked: '$input'. Answer in a short, clear, warm way. If it's a command request, give only the safe command.")
        echo -e "\033[1;32m$response\033[0m"
    fi

    echo -e "\n\033[33mPress Enter to continue • q to quit\033[0m"
    read -s
    clear
done
EOF

chmod +x ~/bin/luna
export PATH="$HOME/bin:$PATH"
echo -e "\033[1;32mLUNA installed! Type: luna\033[0m"
luna
