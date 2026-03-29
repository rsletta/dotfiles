# Neovim

Lua-based config using lazy.nvim for plugin management. Polyglot setup — LSP servers and treesitter parsers load on demand per filetype.

## Core settings (init.lua)

- Leader: Space (local leader: \\)
- System clipboard (unnamedplus)
- Relative line numbers
- No swap files
- Color column at 120
- Auto-removes trailing whitespace on save

## Keybindings (lua/config/keymaps.lua)

| Key | Action |
|-----|--------|
| `<Leader>w` | Save |
| `<Leader>q` | Quit |
| `<Leader>r` | Reload config |
| `<Leader>bn` / `bp` / `bs` | Next / prev / select buffer |
| `]q` / `[q` | Next / prev quickfix |

## Telescope (fuzzy finder)

| Key | Action |
|-----|--------|
| `<Leader>ff` | Find files |
| `<Leader>fg` | Live grep |
| `<Leader>fb` | Buffers |
| `<Leader>fh` | Help tags |
| `<Leader>fx` | File browser |
| `<Leader>fw` | Find in ~/vault |
| `<Leader>fzb` | Fuzzy find in current buffer |
| `<Leader>fr` | LSP references |

Ignores: node_modules, .git, .ruff_cache, .mypy_cache

## LSP

| Key | Action |
|-----|--------|
| `K` | Hover documentation |
| `gd` | Go to definition |
| `gr` | References |
| `[d` / `]d` | Prev / next diagnostic |
| `<Leader>e` | Diagnostic float |

### Configured servers

lua_ls, yamlls, dockerls, docker_compose_language_service, marksman, basedpyright, svelte, tailwindcss, vtsls, jsonls, cssls, html, taplo, gopls, terraformls, helm_ls

Terraform files auto-format on save.

## Treesitter parsers

c, lua, vim, vimdoc, query, yaml, javascript, typescript, html, svelte, css, hcl, terraform

## Theme

Gruvbox (hard contrast) with custom color overrides for keywords, types, functions, strings, and operators.

## Plugin list

| Plugin | Purpose |
|--------|---------|
| lazy.nvim | Plugin manager |
| nvim-lspconfig | LSP configuration |
| telescope.nvim | Fuzzy finder |
| nvim-treesitter | Syntax highlighting + textobjects |
| gruvbox.nvim | Color scheme |
| which-key.nvim | Keybinding hints |
| mini-icons | File icons |
| mini-pairs | Auto-close brackets |
| mini-statusline | Status line |
| markdown-preview | Markdown preview in browser |
| vim-helm | Helm template support |
