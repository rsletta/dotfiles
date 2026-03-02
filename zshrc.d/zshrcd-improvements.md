# `zshrc.d` – Suggested Improvements

This file collects the remaining suggestions for your `zshrc.d` setup, beyond the refactor of `71-contexts.sh`.

---

## 1. `40-completions.sh`

- **Remove `bashcompinit` when possible**
  - You currently have:
    ```zsh
    autoload -Uz compinit bashcompinit
    if [[ -z "$_compinit_done" ]]; then
      compinit
      bashcompinit
      _compinit_done=1
    fi
    ```
  - Once all `complete ...`-style bash completions are migrated to zsh-native `compdef` functions (see section on `70-functions.sh`), you can:
    - Drop `bashcompinit` from the `autoload` line.
    - Remove the `bashcompinit` call.
  - Resulting structure:
    ```zsh
    autoload -Uz compinit
    if [[ -z "$_compinit_done" ]]; then
      compinit
      _compinit_done=1
    fi
    ```

- **Keep `fpath` and `op` completion as-is**
  - The `fpath=(~/.completions $fpath)` and `eval "$(op completion zsh)"; compdef _op op` usage is already zsh-native and good.

---

## 2. `60-aliases.sh`

- **Use zsh-style conditionals for macOS detection**
  - You currently have a POSIX-style test:
    ```zsh
    if [ "$(uname)" = "Darwin" ]; then
      ...
    fi
    ```
  - In pure zsh, you can prefer:
    ```zsh
    if [[ $(uname) == Darwin ]]; then
      ...
    fi
    ```
  - This is more idiomatic and slightly safer (better quoting/word-splitting rules).

---

## 3. `70-functions.sh`

### 3.1. Quoting and robustness

- **Quote paths and arguments**
  - `repos`:
    ```zsh
    repos() {
      cd ~/repositories/$1
    }
    ```
    Suggested:
    ```zsh
    repos() {
      cd "$HOME/repositories/$1" || return
    }
    ```
  - `tla` / `tns`:
    - Wrap command substitutions and `$1` in quotes to avoid issues if names contain spaces:
      ```zsh
      tla() {
        tmux a -t "$(tmux ls -F '#S' | fzf --layout=reverse --border --info=inline --margin=8,20)"
      }

      tns() {
        newTmuxSession "$1"
      }
      ```

### 3.2. Migrate bash-style `complete` to zsh `compdef`

You currently rely on `complete -W ...` with `bashcompinit`. Below are zsh-native suggestions so you can eventually remove `bashcompinit` from `40-completions.sh`.

#### `ku` / `_set_kube_config`

Current pattern:

```zsh
alias ku=_set_kube_config
complete -W "$(ls ~/.kube/config.d)" _set_kube_config
```

Suggested zsh-native approach:

1. Use a function instead of an alias for better completion control:
   ```zsh
   ku() {
     _set_kube_config "$@"
   }
   ```

2. Add a zsh completion function:
   ```zsh
   _ku() {
     local dir configs

     dir="$HOME/.kube/config.d"
     [[ -d $dir ]] || return 0

     configs=(${dir}/*(:t))
     _wanted configs expl 'kube config' compadd -a configs
   }

   compdef _ku ku
   ```

3. Once this is in place, remove the old `complete -W ...` line.

#### `chsp` / `_set_spenn_cli_profile`

Current pattern:

```zsh
alias chsp=_set_spenn_cli_profile
complete -W "$(spenn profile list)" _set_spenn_cli_profile
```

Suggested:

1. Wrap in a function:
   ```zsh
   chsp() {
     _set_spenn_cli_profile "$@"
   }
   ```

2. Add completion using `spenn profile list`:
   ```zsh
   _chsp() {
     local profiles

     profiles=(${(f)"$(spenn profile list 2>/dev/null)"})
     (( ${#profiles} )) || return 0

     _wanted profiles expl 'SPENN CLI profile' compadd -a profiles
   }

   compdef _chsp chsp
   ```

3. Remove the `complete -W` line once this is working.

#### `awsp` / `_set_aws_profile`

Current pattern:

```zsh
alias awsp=_set_aws_profile
complete -W "$(aws configure list-profiles)" _set_aws_profile
```

Suggested:

1. Wrap in a function:
   ```zsh
   awsp() {
     _set_aws_profile "$@"
   }
   ```

2. Add completion using `aws configure list-profiles`:
   ```zsh
   _awsp() {
     local profiles

     profiles=(${(f)"$(aws configure list-profiles 2>/dev/null)"})
     (( ${#profiles} )) || return 0

     _wanted profiles expl 'AWS profile' compadd -a profiles
   }

   compdef _awsp awsp
   ```

3. Remove the `complete -W` line once this is working.

---

## 4. General zsh notes

- **Glob qualifiers**
  - You are already using zsh glob qualifiers like `*.sh(N)` and `(:t)` (e.g., in `71-contexts.sh`).
  - Ensure `setopt extendedglob` is enabled somewhere in your main `.zshrc` so these always behave as expected.

- **Consistency of completion style**
  - `71-contexts.sh` now uses `_func` + `compdef` and `_wanted`/`compadd`.
  - Converting the remaining bash-style completions in `70-functions.sh` to the same pattern:
    - Makes your config more consistent.
    - Allows you to drop `bashcompinit`.
    - Typically improves performance and reliability. 

