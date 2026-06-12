#!/usr/bin/env bash
# NEXUS AI — lib/nexus-figlet.sh - Shared figlet rendering helper

figlet_render() {
    local _text="$1"
    local _color="${2:-96}"
    local _font1="${3:-small}"
    local _font2="${4:-mini}"
    local _font3="${5:-}"
    local _clamp_min="${6:-76}"
    local _clamp_max="${7:-86}"
    
    # Detect terminal width with clamping
    local _cols _bw _inner
    _cols=$(tput cols 2>/dev/null || echo 80)
    _bw=$(( _cols - 2 ))
    [ "$_bw" -lt "$_clamp_min" ] && _bw="$_clamp_min"
    [ "$_bw" -gt "$_clamp_max" ] && _bw="$_clamp_max"
    _inner=$(( _bw - 2 ))
    
    echo ""
    
    # Font chain: font1 → font2 → font3 → uppercase fallback
    local _figlet_printed=false
    if command -v figlet >/dev/null 2>&1; then
        local _figlet_output _max_width _font
        for _font in "$_font1" "$_font2" "$_font3"; do
            if [ -n "$_font" ]; then
                _figlet_output=$(figlet -f "$_font" "$_text" 2>/dev/null)
            else
                _figlet_output=$(figlet "$_text" 2>/dev/null)
            fi
            [ -z "$_figlet_output" ] && continue
            _max_width=$(echo "$_figlet_output" | wc -L)
            if [ "$_max_width" -le "$_inner" ]; then
                printf '\033[%sm%s\033[0m\n' "$_color" "$_figlet_output"
                _figlet_printed=true
                break
            fi
        done
    fi
    
    # Fallback: uppercase + padding
    if [ "$_figlet_printed" != "true" ]; then
        local _fallback
        _fallback=$(echo "$_text" | tr '[:lower:]' '[:upper:]')
        # Calculate padding to center
        local _pad=$(( (_inner - ${#_fallback}) / 2 ))
        [ "$_pad" -lt 0 ] && _pad=0
        printf '\n%*s\033[%sm%s\033[0m\n' "$_pad" '' "$_color" "$_fallback"
    fi
    
    echo ""
}