#!/usr/bin/env bash
# config/categories.sh — Category definitions for NEXUS AI
# Defines CATEGORIES, CATEGORY_ORDER, FLAG_TO_AGENT, AGENT_TO_FLAG
# Provides category_manifest_list, category_manifest_has, agent_get_category
# Version: 0.8.0
#
# Uso: source config/categories.sh (after agents.registry.sh)
# Luego: CATEGORIES[ai], FLAG_TO_AGENT[opencode] etc.

# ── CATEGORIES: category -> space-separated agent names ──────
declare -A CATEGORIES
# Nota: gemini-cli al final — DEPRECATED, sunset 18/6/2026. Reemplazo: agy
CATEGORIES["ai"]="opencode agy claude-code mistral-vibe openclaude openclaw ollama codex engram codegraph pi minimax-cli gentle-ai qwen-code sgpt fabric gemini-cli"
CATEGORIES["editor"]="neovim nvchad"
CATEGORIES["tools"]="gh wget curl bat lsd fzf jq tree make shfmt imagemagick tmate cloudflared bc ncurses translate html2text proot lazygit eza gum git"
CATEGORIES["node"]="typescript nestjs prettier live-server localtunnel vercel markserv psqlformat ncu ngrok nodemon pm2"
CATEGORIES["shell"]="powerlevel10k zsh-defer zsh-autosuggestions zsh-syntax-highlighting history-substring zsh-completions fzf-tab you-should-use zsh-autopair better-npm zsh starship oh-my-zsh"
CATEGORIES["language"]="nodejs python perl php rust clang golang"
CATEGORIES["db"]="postgresql mariadb sqlite mongodb"
CATEGORIES["ui"]="nerd-fonts termux-styling cursor banner"
CATEGORIES["automation"]="n8n"

# ── CATEGORY_ORDER: ordered list of categories ──────────────
declare -a CATEGORY_ORDER=(
    "ai"
    "editor"
    "tools"
    "node"
    "shell"
    "language"
    "db"
    "ui"
    "automation"
)

# ── FLAG_TO_AGENT: short flag -> registry name ──────────────
# Maps '--tool <flag>' to the actual module directory name.
# Most flags match the registry name; exceptions are listed explicitly.
declare -A FLAG_TO_AGENT
# AI
FLAG_TO_AGENT["opencode"]="opencode"
FLAG_TO_AGENT["gemini-cli"]="gemini-cli"
FLAG_TO_AGENT["agy"]="agy"
FLAG_TO_AGENT["claude-code"]="claude-code"
FLAG_TO_AGENT["mistral-vibe"]="mistral-vibe"
FLAG_TO_AGENT["openclaude"]="openclaude"
FLAG_TO_AGENT["openclaw"]="openclaw"
FLAG_TO_AGENT["ollama"]="ollama"
FLAG_TO_AGENT["codex"]="codex"
FLAG_TO_AGENT["engram"]="engram"
FLAG_TO_AGENT["codegraph"]="codegraph"
FLAG_TO_AGENT["pi"]="pi"
FLAG_TO_AGENT["minimax-cli"]="minimax-cli"
FLAG_TO_AGENT["gentle-ai"]="gentle-ai"
FLAG_TO_AGENT["qwen-code"]="qwen-code"
FLAG_TO_AGENT["sgpt"]="sgpt"
FLAG_TO_AGENT["fabric"]="fabric"
# antigravity shares the agy flag
FLAG_TO_AGENT["antigravity"]="antigravity"
# Editor
FLAG_TO_AGENT["neovim"]="neovim"
FLAG_TO_AGENT["nvchad"]="nvchad"
# Tools
FLAG_TO_AGENT["gh"]="gh"
FLAG_TO_AGENT["wget"]="wget"
FLAG_TO_AGENT["curl"]="curl"
FLAG_TO_AGENT["bat"]="bat"
FLAG_TO_AGENT["lsd"]="lsd"
FLAG_TO_AGENT["fzf"]="fzf"
FLAG_TO_AGENT["jq"]="jq"
FLAG_TO_AGENT["tree"]="tree"
FLAG_TO_AGENT["make"]="make"
FLAG_TO_AGENT["shfmt"]="shfmt"
FLAG_TO_AGENT["imagemagick"]="imagemagick"
FLAG_TO_AGENT["tmate"]="tmate"
FLAG_TO_AGENT["cloudflared"]="cloudflared"
FLAG_TO_AGENT["bc"]="bc"
FLAG_TO_AGENT["ncurses"]="ncurses"
FLAG_TO_AGENT["translate"]="translate"
FLAG_TO_AGENT["html2text"]="html2text"
FLAG_TO_AGENT["proot"]="proot"
FLAG_TO_AGENT["lazygit"]="lazygit"
FLAG_TO_AGENT["eza"]="eza"
FLAG_TO_AGENT["gum"]="gum"
FLAG_TO_AGENT["git"]="git"
# Node
FLAG_TO_AGENT["typescript"]="typescript"
FLAG_TO_AGENT["nestjs"]="nestjs"
FLAG_TO_AGENT["prettier"]="prettier"
FLAG_TO_AGENT["live-server"]="live-server"
FLAG_TO_AGENT["localtunnel"]="localtunnel"
FLAG_TO_AGENT["vercel"]="vercel"
FLAG_TO_AGENT["markserv"]="markserv"
FLAG_TO_AGENT["psqlformat"]="psqlformat"
FLAG_TO_AGENT["ncu"]="ncu"
FLAG_TO_AGENT["ngrok"]="ngrok"
FLAG_TO_AGENT["nodemon"]="nodemon"
FLAG_TO_AGENT["pm2"]="pm2"
# Shell
FLAG_TO_AGENT["powerlevel10k"]="powerlevel10k"
FLAG_TO_AGENT["zsh-defer"]="zsh-defer"
FLAG_TO_AGENT["zsh-autosuggestions"]="zsh-autosuggestions"
FLAG_TO_AGENT["zsh-syntax-highlighting"]="zsh-syntax-highlighting"
FLAG_TO_AGENT["history-substring"]="history-substring"
FLAG_TO_AGENT["zsh-completions"]="zsh-completions"
FLAG_TO_AGENT["fzf-tab"]="fzf-tab"
FLAG_TO_AGENT["you-should-use"]="you-should-use"
FLAG_TO_AGENT["zsh-autopair"]="zsh-autopair"
FLAG_TO_AGENT["better-npm"]="better-npm"
FLAG_TO_AGENT["zsh"]="zsh"
FLAG_TO_AGENT["starship"]="starship"
FLAG_TO_AGENT["oh-my-zsh"]="oh-my-zsh"
# Language
FLAG_TO_AGENT["nodejs"]="nodejs"
FLAG_TO_AGENT["python"]="python"
FLAG_TO_AGENT["perl"]="perl"
FLAG_TO_AGENT["php"]="php"
FLAG_TO_AGENT["rust"]="rust"
FLAG_TO_AGENT["clang"]="clang"
FLAG_TO_AGENT["golang"]="golang"
# DB
FLAG_TO_AGENT["postgresql"]="postgresql"
FLAG_TO_AGENT["mariadb"]="mariadb"
FLAG_TO_AGENT["sqlite"]="sqlite"
FLAG_TO_AGENT["mongodb"]="mongodb"
# UI — exceptions: nerd-fonts flag=font, termux-styling flag=extra-keys
FLAG_TO_AGENT["font"]="nerd-fonts"
FLAG_TO_AGENT["extra-keys"]="termux-styling"
FLAG_TO_AGENT["cursor"]="cursor"
FLAG_TO_AGENT["banner"]="banner"
# Automation
FLAG_TO_AGENT["n8n"]="n8n"

# ── AGENT_TO_FLAG: registry name -> short flag ──────────────
# Reverse mapping for display and resolution.
# Most agents use their own name; exceptions are listed explicitly.
declare -A AGENT_TO_FLAG
# AI
AGENT_TO_FLAG["opencode"]="opencode"
AGENT_TO_FLAG["gemini-cli"]="gemini-cli"
AGENT_TO_FLAG["agy"]="agy"
AGENT_TO_FLAG["antigravity"]="agy"
AGENT_TO_FLAG["claude-code"]="claude-code"
AGENT_TO_FLAG["mistral-vibe"]="mistral-vibe"
AGENT_TO_FLAG["openclaude"]="openclaude"
AGENT_TO_FLAG["openclaw"]="openclaw"
AGENT_TO_FLAG["ollama"]="ollama"
AGENT_TO_FLAG["codex"]="codex"
AGENT_TO_FLAG["engram"]="engram"
AGENT_TO_FLAG["codegraph"]="codegraph"
AGENT_TO_FLAG["pi"]="pi"
AGENT_TO_FLAG["minimax-cli"]="minimax-cli"
AGENT_TO_FLAG["gentle-ai"]="gentle-ai"
AGENT_TO_FLAG["qwen-code"]="qwen-code"
AGENT_TO_FLAG["sgpt"]="sgpt"
AGENT_TO_FLAG["fabric"]="fabric"
# Editor
AGENT_TO_FLAG["neovim"]="neovim"
AGENT_TO_FLAG["nvchad"]="nvchad"
# Tools
AGENT_TO_FLAG["gh"]="gh"
AGENT_TO_FLAG["wget"]="wget"
AGENT_TO_FLAG["curl"]="curl"
AGENT_TO_FLAG["bat"]="bat"
AGENT_TO_FLAG["lsd"]="lsd"
AGENT_TO_FLAG["fzf"]="fzf"
AGENT_TO_FLAG["jq"]="jq"
AGENT_TO_FLAG["tree"]="tree"
AGENT_TO_FLAG["make"]="make"
AGENT_TO_FLAG["shfmt"]="shfmt"
AGENT_TO_FLAG["imagemagick"]="imagemagick"
AGENT_TO_FLAG["tmate"]="tmate"
AGENT_TO_FLAG["cloudflared"]="cloudflared"
AGENT_TO_FLAG["bc"]="bc"
AGENT_TO_FLAG["ncurses"]="ncurses"
AGENT_TO_FLAG["translate"]="translate"
AGENT_TO_FLAG["html2text"]="html2text"
AGENT_TO_FLAG["proot"]="proot"
AGENT_TO_FLAG["lazygit"]="lazygit"
AGENT_TO_FLAG["eza"]="eza"
AGENT_TO_FLAG["gum"]="gum"
AGENT_TO_FLAG["git"]="git"
# Node
AGENT_TO_FLAG["typescript"]="typescript"
AGENT_TO_FLAG["nestjs"]="nestjs"
AGENT_TO_FLAG["prettier"]="prettier"
AGENT_TO_FLAG["live-server"]="live-server"
AGENT_TO_FLAG["localtunnel"]="localtunnel"
AGENT_TO_FLAG["vercel"]="vercel"
AGENT_TO_FLAG["markserv"]="markserv"
AGENT_TO_FLAG["psqlformat"]="psqlformat"
AGENT_TO_FLAG["ncu"]="ncu"
AGENT_TO_FLAG["ngrok"]="ngrok"
AGENT_TO_FLAG["nodemon"]="nodemon"
AGENT_TO_FLAG["pm2"]="pm2"
# Shell
AGENT_TO_FLAG["powerlevel10k"]="powerlevel10k"
AGENT_TO_FLAG["zsh-defer"]="zsh-defer"
AGENT_TO_FLAG["zsh-autosuggestions"]="zsh-autosuggestions"
AGENT_TO_FLAG["zsh-syntax-highlighting"]="zsh-syntax-highlighting"
AGENT_TO_FLAG["history-substring"]="history-substring"
AGENT_TO_FLAG["zsh-completions"]="zsh-completions"
AGENT_TO_FLAG["fzf-tab"]="fzf-tab"
AGENT_TO_FLAG["you-should-use"]="you-should-use"
AGENT_TO_FLAG["zsh-autopair"]="zsh-autopair"
AGENT_TO_FLAG["better-npm"]="better-npm"
AGENT_TO_FLAG["zsh"]="zsh"
AGENT_TO_FLAG["starship"]="starship"
AGENT_TO_FLAG["oh-my-zsh"]="oh-my-zsh"
# Language
AGENT_TO_FLAG["nodejs"]="nodejs"
AGENT_TO_FLAG["python"]="python"
AGENT_TO_FLAG["perl"]="perl"
AGENT_TO_FLAG["php"]="php"
AGENT_TO_FLAG["rust"]="rust"
AGENT_TO_FLAG["clang"]="clang"
AGENT_TO_FLAG["golang"]="golang"
# DB
AGENT_TO_FLAG["postgresql"]="postgresql"
AGENT_TO_FLAG["mariadb"]="mariadb"
AGENT_TO_FLAG["sqlite"]="sqlite"
AGENT_TO_FLAG["mongodb"]="mongodb"
# UI — exceptions: nerd-fonts → font, termux-styling → extra-keys
AGENT_TO_FLAG["nerd-fonts"]="font"
AGENT_TO_FLAG["termux-styling"]="extra-keys"
AGENT_TO_FLAG["cursor"]="cursor"
AGENT_TO_FLAG["banner"]="banner"
# Automation
AGENT_TO_FLAG["n8n"]="n8n"


