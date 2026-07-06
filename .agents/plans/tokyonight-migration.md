# Tokyo Night (night) migration

Switch whole stack from gruvbox → Tokyo Night `night` variant (highest contrast; eyesight priority). wezterm/zellij already on `storm` → move to `night` for consistency.

Verified theme names on machine: ghostty `TokyoNight Night`; wezterm builtin `Tokyo Night`; zellij builtin `tokyo-night`; vivid builtin `tokyonight-night` (being removed).

Decisions:
- nvim gruvbox treesitter overrides: DROP (were gruvbox workarounds). Run stock Tokyo Night.
- vivid: legacy/unused → remove entirely (dir + doc refs).
- `nvim/colors/oh-my-eyes.lua`: leave untouched (inactive custom scheme).

## Tasks
1. [x] Ghostty — `ghostty/config.ghostty`: `theme = TokyoNight Night` (verified: reloaded)
2. [x] wezterm — `wezterm/wezterm.lua`: `'Tokyo Night'` (dup is a symlink)
3. [x] zellij — `zellij/config.kdl`: `theme "tokyo-night"`
4. [x] Neovim — deleted `gruvbox.lua`, added `tokyonight.lua` (`folke/tokyonight.nvim`, `style="night"`, no overrides). Verified headless: `colors_name = tokyonight-night`
5. [x] Vim — `.vimrc` DELETED. Was an orphan (not symlinked; `vim`→`nvim` alias; contained nvim-only plugins). Classic vim unused for years.
6. [x] tmux — `fabioluciano/tmux-tokyo-night` (`@theme_variation 'night'`), plugin installed via tpm. NEEDS: `prefix+r` reload + eyeball status-bar modules
7. [x] vivid — removed `vivid/` dir + refs in `applications.md`, `AGENTS.md` (was legacy/unused, not wired into shell)
8. [x] Docs — updated `README.md`, `docs/terminal.md`, `docs/neovim.md`, `AGENTS.md`, `applications.md`

Follow-up: herdr theming split out to [[herdr-setup]].
