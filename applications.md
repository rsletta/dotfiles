# Applications

Inventory of what's installed and why. Not automated — update when things change.

## Terminal & Shell

| App | Source | Notes |
|-----|--------|-------|
| Ghostty | brew cask | Primary terminal |
| tmux | brew | Terminal multiplexer |
| iTerm | brew cask | Fallback terminal |
| WezTerm | brew cask (nightly) | Experimental |
| starship | brew | Shell prompt |
| neovim | brew | Editor |

## CLI Tools — Daily Use

| Tool | Source | What it does |
|------|--------|-------------|
| eza | brew | Modern ls replacement |
| zoxide | brew | Smart cd with history |
| fzf | brew | Fuzzy finder |
| bat | brew | cat with syntax highlighting |
| fd | brew | Modern find replacement |
| ripgrep | brew | Fast grep |
| lazygit | brew | Git TUI |
| lazydocker | brew | Docker TUI |
| htop / btop / bottom | brew | Process monitors |
| tree | brew | Directory tree view |
| tldr | brew | Simplified man pages |
| watch | brew | Repeat commands |
| wget | brew | Download files |
| jq / yq | brew | JSON/YAML processors |
| gh | brew | GitHub CLI |
| git-lfs | brew | Git large file storage |
| git-filter-repo | brew | Git history rewriting |
| tig | brew | Git log viewer |
| ncdu | brew | Disk usage analyzer |
| nnn / ranger | brew | Terminal file managers |
| coreutils | brew | GNU core utilities |

## Cloud & Infrastructure

| Tool | Source | What it does |
|------|--------|-------------|
| awscli / aws-shell | brew | AWS CLI |
| azure-cli | brew | Azure CLI |
| azure-functions-core-tools | brew | Azure Functions local dev |
| kubernetes-cli | brew | kubectl |
| k9s | brew | Kubernetes TUI |
| helm / helmfile | brew | Kubernetes package management |
| helm-ls | brew | Helm language server |
| stern | brew | Multi-pod log tailing |
| kind | brew | Local Kubernetes clusters |
| terraform / opentofu | brew | Infrastructure as code |
| terraform-ls | brew | Terraform language server |
| talosctl | brew | Talos Linux cluster management |
| telepresence-oss | brew | Local-to-cluster development |
| cloudflared | brew | Cloudflare tunnel |
| sops | brew | Encrypted secrets (with age) |
| age | brew | Encryption tool (used with sops) |
| Docker | manual | Container runtime |

## Development — Languages & Runtimes

| Tool | Source | What it does |
|------|--------|-------------|
| fnm | brew | Node version manager |
| uv | brew | Python package manager |
| pipx | brew | Install Python CLI tools |
| python@3.11 / 3.13 / 3.14 | brew | Python runtimes |
| go | brew | Go language |
| ruby | brew | Ruby (CocoaPods dependency) |
| dotnet@9 | brew | .NET runtime |
| mvnvm | brew | Maven version manager |
| kdoctor | brew | Kotlin Multiplatform diagnostics |
| fvm | brew | Flutter version manager (not actively used) |
| deno | brew | Deno runtime |

## Development — Editors & IDEs

| App | Source | Notes |
|-----|--------|-------|
| Visual Studio Code | brew cask | |
| Zed | manual | |
| Cursor | brew cask | AI editor |
| JetBrains Toolbox | manual | Manages IntelliJ, DataGrip, etc. |

## Development — API & Data

| App | Source | Notes |
|-----|--------|-------|
| Postman | brew cask | API testing |
| Bruno | brew cask | API testing (Postman alternative, evaluating) |
| Insomnia | brew cask | API testing |
| DB Browser for SQLite | brew cask | SQLite viewer |
| DBeaver | brew cask | Database client |
| DBngin | brew cask | Local database management |
| Microsoft Azure Storage Explorer | manual | Azure blob/table storage |

## Development — Other CLI

| Tool | Source | What it does |
|------|--------|-------------|
| kafka / kafkactl / kcat | brew | Kafka tooling |
| avro-tools | brew | Avro schema tools |
| openapi-generator | brew | Generate code from OpenAPI specs |
| redocly-cli | brew | OpenAPI linting |
| postgresql@14 | brew | Local PostgreSQL |
| valkey | brew | Redis-compatible key-value store |
| csvkit | brew | CSV processing |
| pandoc | brew | Document conversion |
| tesseract | brew | OCR |
| cloc | brew | Count lines of code |

## Language Servers & Formatters

| Tool | Source | What it does |
|------|--------|-------------|
| lua-language-server | brew | Lua LSP |
| marksman | brew | Markdown LSP |
| taplo | brew | TOML LSP/formatter |
| gnupg | brew | GPG signing |

## AI Tools

| App | Source | Notes |
|-----|--------|-------|
| Claude | manual | Claude desktop app |
| claude-code | brew cask | Claude Code CLI |
| copilot-cli | brew cask | GitHub Copilot CLI |
| LM Studio | manual | Local LLM runner |
| block-goose-cli | brew | Goose AI agent (testing) |
| opencode | brew | AI coding tool (testing) |

## macOS Utilities

| App | Source | Notes |
|-----|--------|-------|
| Raycast | manual | Launcher, replaced Spotlight and Rocket |
| Hyperkey | brew cask | Caps Lock as hyper key (Shift+Ctrl+Opt+Cmd) |
| Easy Move+Resize | brew cask | Window management |
| Hazel | brew cask | Automated file cleanup |
| Hammerspoon | brew cask | macOS automation (want to explore) |
| Stats | brew cask | Menu bar system monitor |
| BetterDisplay | manual | Display management |
| Marta | brew cask | Dual-pane file manager |
| Numi | brew cask | Calculator |
| Shottr | brew cask | Screenshot tool |
| Pearcleaner | brew cask | App uninstaller |
| 1Password | manual | Password manager |
| 1password-cli | brew cask | 1Password CLI (op) |
| HEIC Converter | manual (App Store) | Image format converter |
| Color Picker | manual (App Store) | Color picker utility |
| Gifski | manual | Video to GIF converter |

## Communication

| App | Source | Notes |
|-----|--------|-------|
| Slack | manual | |
| Microsoft Teams | manual | |
| Microsoft Outlook | manual | |
| Signal | manual | |
| Discord | manual | |

## Microsoft Office

| App | Source | Notes |
|-----|--------|-------|
| Microsoft Word | manual | |
| Microsoft Excel | manual | |
| Microsoft PowerPoint | manual | |
| OneDrive | manual | |
| Microsoft Remote Desktop | manual | |

## Browsers

| App | Source | Notes |
|-----|--------|-------|
| Vivaldi | manual | Primary browser |
| Google Chrome | manual | |
| Firefox Developer Edition | manual | |
| Safari | system | |

## Media

| App | Source | Notes |
|-----|--------|-------|
| IINA | brew cask | Video player |
| VLC | brew cask | Media player |
| Audacity | brew cask | Audio editor |
| HandBrake | brew cask | Video transcoder |
| OBS | brew cask | Screen recording / streaming |
| ffmpeg | brew | Video/audio CLI tool |
| yt-dlp | brew | Video downloader |
| MediaDownloader | manual | YouTube downloader (GUI) |
| Amperfy | manual (App Store) | Music player for self-hosted Ampache/Subsonic |
| Dark Noise | manual (App Store) | Background noise generator |
| Spotify | manual | Music streaming |

## Other

| App | Source | Notes |
|-----|--------|-------|
| Obsidian | manual | Notes / knowledge base |
| Notion | manual | _(in old list, verify if still installed)_ |
| LocalSend | brew cask | AirDrop alternative (cross-platform) |
| Tailscale | manual | VPN / mesh networking |
| WireGuard | manual | VPN |
| balenaEtcher | brew cask | Flash OS images to USB/SD |
| Elgato Stream Deck | manual | Stream Deck hardware control |
| Bulder | manual (App Store) | Bank app |
| Xcode | manual (App Store) | Apple development tools |
| basictex | brew cask | Minimal LaTeX distribution |

## Fun & Miscellaneous CLI

| Tool | Source | What it does |
|------|--------|-------------|
| figlet | brew | ASCII art text |
| toilet | brew | Colored ASCII art text |
| cmatrix | brew | Matrix rain animation |
| asciinema | brew | Terminal session recording |
| asciiquarium | brew | ASCII aquarium |
| toipe | brew | Typing test |
| fastfetch / neofetch | brew | System info display |
| ddgr | brew | DuckDuckGo from terminal |
| gource | brew | Git history visualization |
| vivid | brew | LS_COLORS theme generator |

## Fonts (brew cask)

- CaskaydiaMono Nerd Font
- Hack Nerd Font
- JetBrains Mono
- Noto Color Emoji
- Twitter Color Emoji

## Not actively used / candidates for removal

| App | Reason |
|-----|--------|
| Warp | Not using, have Ghostty + tmux |
| rio | Not using, removed from dotfiles |
| Overkill | Was for killing iTunes, no longer needed |
| Rocket | Emoji picker, Raycast replaced it |
| toggle_natural_scrolling | Leftover from test |
| Insomnia | Bruno/Postman cover this |

## Brew install snippet

```bash
# Core CLI tools
brew install eza zoxide fzf bat fd ripgrep lazygit htop btop bottom tree tldr watch wget jq yq gh git-lfs tig ncdu coreutils tmux neovim starship

# Cloud & infrastructure
brew install awscli azure-cli kubernetes-cli k9s helm helmfile stern kind terraform opentofu talosctl sops age cloudflared

# Development
brew install fnm uv go ruby dotnet@9 deno

# Language servers
brew install lua-language-server marksman taplo terraform-ls helm-ls

# Media
brew install ffmpeg yt-dlp

# Casks
brew install --cask ghostty iterm2 visual-studio-code 1password-cli figma bruno dbeaver-community hammerspoon hyperkey easy-move+resize hazel stats marta numi shottr pearcleaner iina vlc audacity handbrake obs localsend balenaetcher claude-code
```
