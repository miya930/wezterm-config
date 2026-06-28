# dotfiles

個人の設定ファイル置き場。

## 中身

- `.wezterm.lua` — [WezTerm](https://wezfurlong.org/wezterm/) の設定
- `git/aliases.gitconfig` — git のエイリアス
- `install.sh` — セットアップスクリプト

## セットアップ（新しい環境）

```sh
git clone https://github.com/miya930/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` がやること（冪等・再実行しても安全）:

- **WezTerm**: `.wezterm.lua` を配置（Linux/macOS は symlink、WSL は Windows の `%USERPROFILE%` へコピー）
- **git**: `~/.gitconfig` から `git/aliases.gitconfig` を include
- 既存ファイルは `.backup.*` に退避

## 手動で設定する場合

- WezTerm: `.wezterm.lua` を `~/.wezterm.lua`（Windows は `%USERPROFILE%\.wezterm.lua`）に置く
- git: `~/.gitconfig` に追記
  ```ini
  [include]
  	path = ~/dotfiles/git/aliases.gitconfig
  ```
