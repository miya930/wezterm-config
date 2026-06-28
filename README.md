# dotfiles

個人の設定ファイル置き場。

## 中身

- `.wezterm.lua` — [WezTerm](https://wezfurlong.org/wezterm/) の設定
- `git/aliases.gitconfig` — git のエイリアス

## 使い方

**WezTerm**: `.wezterm.lua` を設定場所に置く。
- Windows: `%USERPROFILE%\.wezterm.lua`
- Linux / macOS: `~/.wezterm.lua`

**git エイリアス**: `~/.gitconfig` に include を1行足す。
```ini
[include]
	path = ~/dotfiles/git/aliases.gitconfig
```
