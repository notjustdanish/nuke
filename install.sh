
#!/bin/bash
echo -e "\033[1;31m
   _   __      __      __
  / | / /_  __/ /_____/_/
 /  |/ / / / / //_/ _/_/
/_/|_/ /___/ /_/  /___/
      v2 — cloud powered by wtf.mr
\033[0m"

mkdir -p ~/bin
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

cat > ~/bin/nuke << 'EOF'
#!/bin/bash
clear
echo -e "\033[1;31m
   _   __      __      __
  / | / /_  __/ /_____/_/
 /  |/ / / / / //_/ _/_/
/_/|_/ /___/ /_/  /___/
      v2 — choose your brain
\033[0m"

CONFIG="$HOME/.nuke_config"

select_model() {
    echo -e "\033[33mSelect your LLM:\033[0m"
    echo "1) Google Gemini 1.5 Flash (FREE + unlimited)"
    echo "2) Groq Llama3-70B (INSANE speed + free tier)"
    echo "3) OpenAI GPT-4o / 4o-mini"
    echo "4) OpenRouter (Claude-3.5, Mixtral, etc)"
    read -p "Choose 1-4: " choice

    case $choice in
        1) PROVIDER="gemini"; read -p "Gemini API Key (get free at https://aistudio.google.com/app/apikey): " key; echo "GEMINI_KEY=$key" > "$CONFIG" ;;
        2) PROVIDER="groq";   read -p "Groq API Key[](https://console.groq.com/keys): " key; echo "GROQ_KEY=$key" >> "$CONFIG" ;;
        3) PROVIDER="openai"; read -p "OpenAI API Key: " key; echo "OPENAI_KEY=$key" >> "$CONFIG" ;;
        4) PROVIDER="openrouter"; read -p "OpenRouter API Key[](https://openrouter.ai/keys): " key; echo "OR_KEY=$key" >> "$CONFIG" ;;
        *) echo "Invalid"; exit 1 ;;
    esac
    echo "PROVIDER=$PROVIDER" >> "$CONFIG"
    echo -e "\033[32mSaved! Now just type: nuke\033[0m"
    exit 0
}

[[ ! -f "$CONFIG" ]] && select_model
source "$CONFIG"

send() {
    query="$1"
    case $PROVIDER in
        gemini)
            curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_KEY" \
                -H 'Content-Type: application/json' \
                -d '{"contents":[{"role":"user","parts":[{"text":"You are KaliGPT. Give ONLY the single best command for: '"$query"'"}]}]}' \
                | jq -r '.candidates[0].content.parts[0].text' 2>/dev/null || echo "API error"
            ;;
        groq)
            curl -s https://api.groq.com/openai/v1/chat/completions \
                -H "Authorization: Bearer $GROQ_KEY" \
                -H "Content-Type: application/json" \
                -d '{"model":"llama3-70b-8192","messages":[{"role":"user","content":"Kali expert: ONLY the command for: '"$query"'"}],"temperature":0.3}' \
                | jq -r '.choices[0].message.content' 2>/dev/null
            ;;
        openai)
            curl -s https://api.openai.com/v1/chat/completions \
                -H "Authorization: Bearer $OPENAI_KEY" \
                -H "Content-Type: application/json" \
                -d '{"model":"gpt-4o-mini","messages":[{"role":"user","content":"Kali expert: ONLY the command for: '"$query"'"}],"temperature":0}' \
                | jq -r '.choices[0].message.content' 2>/dev/null
            ;;
        openrouter)
            curl -s https://openrouter.ai/api/v1/chat/completions \
                -H "Authorization: Bearer $OR_KEY" \
                -H "HTTP-Referer: https://github.com/notjustdanish/nuke" \
                -d '{"model":"anthropic/claude-3.5-sonnet","messages":[{"role":"user","content":"Kali expert: ONLY the command for: '"$query"'"}]}' \
                | jq -r '.choices[0].message.content' 2>/dev/null
            ;;
    esac
}

while :; do
    read -p "▸ " q
    [[ "$q" =~ ^[qQ]$ ]] && { clear; echo -e "\033[31mStay dangerous ☢️\033[0m"; exit; }
    echo -e "\033[90mthinking...\033[0m"
    resp=$(send "$q")
    [[ -z "$resp" || "$resp" == "null" ]] && resp="API error — check key"
    echo -e "\033[32m$resp\033[0m"
    read -n1 -p $'\033[33m[r] Run • [ENTER] Copy • [c] Change model • [q] Quit → \033[0m' k; echo
    case "$k" in
        r) echo "$resp" | bash 2>/dev/null || echo -e "\033[31mfailed\033[0m"; read -n1 ;;
        "") echo "$resp" | xclip -selection clipboard; echo -e "\033[32mCopied!\033[0m" ;;
        c) rm "$CONFIG"; echo "Config cleared — restart nuke to choose again"; exit ;;
    esac
    clear
    echo -e "\033[1;31mNUKE v2 — $PROVIDER mode\033[0m"
done
EOF

chmod +x ~/bin/nuke
echo -e "\033[1;32mInstalled! Type: nuke\033[0m"
