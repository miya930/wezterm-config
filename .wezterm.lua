local wezterm = require 'wezterm'
local config = wezterm.config_builder() -- エラーが分かりやすくなる新方式

config.automatically_reload_config = true

-- 外観
config.color_scheme = 'Ayu Mirage' -- 旧 color_schema(誤) を修正、これで実際に効く
config.colors = { background = '#000000' } -- 背景のみ黒で上書き（文字色は AdventureTime のまま）
config.font = wezterm.font_with_fallback {
  'Cascadia Code', -- インストール済み（JetBrainsMono Nerd Font は未導入のため削除）
  'B612 Mono',
  'Consolas',
  -- Powerline/アイコン用グリフは WezTerm 内蔵の Symbols Nerd Font Mono が自動で担う
}
config.font_size = 12
config.line_height = 1.1

config.window_background_opacity = 0.85 -- 背景の透過（好みで 0.0〜1.0）
config.window_decorations = 'INTEGRATED_BUTTONS | RESIZE' -- OSタイトルバーを消し、ボタンをタブバーに統合
config.window_padding = { left = 8, right = 8, top = 6, bottom = 4 }

-- カーソル / スクロール
config.default_cursor_style = 'BlinkingBar'
config.scrollback_lines = 10000

-- タブバー
config.hide_tab_bar_if_only_one_tab = false -- 統合ボタンを常時出すため非表示にしない
config.show_new_tab_button_in_tab_bar = false
config.use_fancy_tab_bar = true
config.tab_max_width = 32

-- タイトルバー（統合ボタン）の見た目
config.window_frame = {
  font = wezterm.font { family = 'Cascadia Code', weight = 'Bold' },
  font_size = 11,
  active_titlebar_bg = '#0b0b0b',
  inactive_titlebar_bg = '#0b0b0b',
}
config.integrated_title_button_style = 'Windows'
config.integrated_title_button_alignment = 'Right'

-- 非アクティブなペインを少し暗くして視線を誘導
config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.7 }

config.default_prog = { 'wsl.exe' }

-- ペイン分割（任意。要らなければこの keys ブロックを削除）
config.keys = {
  { key = 'd', mods = 'CTRL|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'e', mods = 'CTRL|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
}

-- ② Powerline 風タブ（区切りグリフは内蔵 Symbols Nerd Font で表示）
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_right_hard_divider -- 右向き区切り
local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_left_hard_divider   -- 左向き区切り
local TAB_EDGE = '#0b0b0b'   -- タブバー背景
local ACTIVE_BG = '#ae8b2d'  -- アクティブタブ（gold）
local ACTIVE_FG = '#0b0b0b'
local INACTIVE_BG = '#3a3f4b'
local INACTIVE_FG = '#cfd2d6'

-- パス等から末尾要素（ファイル/フォルダ/プロセス名）を取り出す
local function basename(s)
  if not s then return nil end
  return (s:gsub('[/\\]+$', '')):match('([^/\\]+)$')
end

wezterm.on('format-tab-title', function(tab, tabs, panes, conf, hover, max_width)
  local bg = tab.is_active and ACTIVE_BG or INACTIVE_BG
  local fg = tab.is_active and ACTIVE_FG or INACTIVE_FG
  -- シェル側で「実行中コマンド／待機中は bash」をタイトルに設定済み（cwd は出さない）
  local pane_title = tab.active_pane.title
  if pane_title == nil or pane_title == '' then pane_title = 'shell' end
  local title = ' ' .. (tab.tab_index + 1) .. ': ' .. pane_title .. ' '
  title = wezterm.truncate_right(title, max_width - 2)
  return {
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Text = title },
    { Background = { Color = TAB_EDGE } },
    { Foreground = { Color = bg } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

-- ③ 右上ステータス（実用情報を Powerline 風に表示。値が無い項目は省略）
wezterm.on('update-right-status', function(window, pane)
  local segments = {}

  -- 実行中のプロセス名
  local proc = basename(pane:get_foreground_process_name())
  if proc then
    table.insert(segments, { text = ' ' .. proc .. ' ', fg = '#cdd1d6', bg = '#2f3340' })
  end

  -- 時計
  table.insert(segments, { text = ' ' .. wezterm.strftime('%m/%d (%a) %H:%M') .. ' ', fg = '#e6e6e6', bg = '#1c1f26' })

  -- Powerline 風に連結（左向き区切り）
  local elements = {}
  for i, seg in ipairs(segments) do
    local left_bg = (i == 1) and TAB_EDGE or segments[i - 1].bg
    table.insert(elements, { Background = { Color = left_bg } })
    table.insert(elements, { Foreground = { Color = seg.bg } })
    table.insert(elements, { Text = SOLID_LEFT_ARROW })
    table.insert(elements, { Background = { Color = seg.bg } })
    table.insert(elements, { Foreground = { Color = seg.fg } })
    table.insert(elements, { Text = seg.text })
  end
  window:set_right_status(wezterm.format(elements))
end)

return config
