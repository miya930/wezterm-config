#!/usr/bin/env bash
# dotfiles セットアップ。クローン後にこれを実行すると各設定を反映する。
# 冪等（再実行しても安全）。既存ファイルは必要時のみ .backup.* に退避する。
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

c_ok=$'\033[1;32m'; c_warn=$'\033[1;33m'; c_off=$'\033[0m'
log()  { printf '%s[dotfiles]%s %s\n' "$c_ok"   "$c_off" "$*"; }
warn() { printf '%s[dotfiles]%s %s\n' "$c_warn" "$c_off" "$*"; }

is_wsl() { grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null; }

backup() {
  local t="$1"
  if [ -e "$t" ] || [ -L "$t" ]; then
    local b="${t}.backup.$(date +%Y%m%d%H%M%S)"
    mv "$t" "$b"
    warn "既存を退避: $t -> $b"
  fi
}

# WSL で Windows の %USERPROFILE% を WSL パスに変換
get_winhome() {
  local up
  up="$(cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r\n')" || return 1
  [ -n "$up" ] || return 1
  wslpath "$up" 2>/dev/null
}

# WezTerm 設定: Linux/macOS は symlink、WSL は Windows 側へコピー
setup_wezterm() {
  local src="$DOTFILES/.wezterm.lua" dst
  if is_wsl; then
    local winhome
    if ! winhome="$(get_winhome)"; then
      warn "WezTerm: Windows ホームを取得できずスキップ"; return 0
    fi
    dst="$winhome/.wezterm.lua"
    if [ -f "$dst" ] && cmp -s "$src" "$dst"; then
      log "WezTerm: 既に最新（$dst）"; return 0
    fi
    backup "$dst"
    cp "$src" "$dst"
    log "WezTerm: コピー -> $dst （WSL→Windows）"
  else
    dst="$HOME/.wezterm.lua"
    if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
      log "WezTerm: 既に symlink 済み（$dst）"; return 0
    fi
    backup "$dst"
    ln -s "$src" "$dst"
    log "WezTerm: symlink $dst -> $src"
  fi
}

# git エイリアス: ~/.gitconfig から include（パスを解決して重複登録を防ぐ）
setup_git() {
  local inc="$DOTFILES/git/aliases.gitconfig" p exp
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    exp="${p/#\~/$HOME}"
    if [ "$(readlink -f "$exp" 2>/dev/null)" = "$(readlink -f "$inc" 2>/dev/null)" ]; then
      log "git: include 既に設定済み"; return 0
    fi
  done < <(git config --global --get-all include.path 2>/dev/null || true)
  git config --global --add include.path "$inc"
  log "git: include 追加 -> $inc"
}

main() {
  log "dotfiles をセットアップします（$DOTFILES）"
  setup_wezterm
  setup_git
  log "完了"
}

# 直接実行時のみ走らせる（source 時はテスト等で関数だけ使える）
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  main "$@"
fi
