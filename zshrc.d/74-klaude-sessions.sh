# Inspect, analyze, and prune Claude Code session JSONLs across all contexts.
# Subcommand pattern mirrors cman / ws.

_KLAUDE_SESSIONS_ROOT="$HOME/.config/contexts"

_klaude_sessions_help() {
  cat >&2 <<'EOF'
Usage: klaude-sessions <subcommand> [args]

  list [--context X] [--since W] [--limit N] [--tsv] [--no-header]
      List sessions across all contexts (sorted newest first).
      Active session (current cwd, last record <5min ago) is marked with *.

  show <uuid|prefix|"last">
      Pretty-print one session, paged when interactive.

  stats [--by day|project|tool|model|context] [--context X] [--since W]
      Aggregate metrics. No --by → totals + per-context breakdown.

  grep <pattern> [--context X] [--in user|assistant|tool|all]
      Search inside session content (extended regex).

  delete|rm <uuid|prefix> [--force]
      Remove one session (.jsonl + sibling dir). Confirms unless --force.

  prune [--older-than W] [--context X] [--force]
      Bulk-delete by filter. Lists victims and confirms.

  orphans [--delete] [--force]
      List <uuid>/ dirs lacking a sibling .jsonl. --delete cleans them.

  help
      Show this help.

  --since accepts: today | yesterday | Nd | YYYY-MM-DD
EOF
}

_klaude_sessions_format_dur() {
  local s="$1"
  if (( s < 60 )); then printf '%ds' "$s"
  elif (( s < 3600 )); then printf '%dm' "$((s / 60))"
  elif (( s < 86400 )); then printf '%dh%02dm' "$((s / 3600))" "$(((s % 3600) / 60))"
  else printf '%dd%02dh' "$((s / 86400))" "$(((s % 86400) / 3600))"
  fi
}

_klaude_sessions_format_kn() {
  LC_ALL=C awk -v n="$1" 'BEGIN {
    if (n < 1000) printf "%d", n
    else if (n < 10000) printf "%.1fk", n/1000
    else if (n < 1000000) printf "%dk", n/1000
    else printf "%.1fM", n/1000000
  }'
}

_klaude_sessions_parse_since() {
  local expr="$1"
  case "$expr" in
    today)     date -j -v0H -v0M -v0S +%s ;;
    yesterday) date -j -v-1d -v0H -v0M -v0S +%s ;;
    [0-9]*d)   date -j -v"-${expr%d}d" +%s ;;
    [0-9]*m)   date -j -v"-${expr%m}m" +%s ;;
    [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])
               date -j -f "%Y-%m-%d" "$expr" +%s ;;
    *)         echo "Invalid time expr: $expr (use today|yesterday|Nd|Nm|YYYY-MM-DD)" >&2; return 1 ;;
  esac
}

_klaude_sessions_ts_to_epoch() {
  # Tolerant ISO8601 → epoch (BSD date, ignores fractional seconds + trailing Z)
  local ts="${1:0:19}"
  date -j -f "%Y-%m-%dT%H:%M:%S" "$ts" +%s 2>/dev/null
}

_klaude_sessions_discover() {
  local f
  for f in "$_KLAUDE_SESSIONS_ROOT"/*/tools/claude/projects/*/*.jsonl(N); do
    print -r -- "$f"
  done
}

_klaude_sessions_extract() {
  # Emits one TSV row: uuid, first_ts, last_ts, ctx, project, msgs, tokens, cwd, first_prompt
  local f="$1"
  local uuid="${f:t:r}"
  local ctx="${f:h:h:h:h:h:t}"

  local files=("$f")
  if [[ -d "${f:r}/subagents" ]]; then
    files+=("${f:r}"/subagents/*.jsonl(N))
  fi

  jq -s -r --arg uuid "$uuid" --arg ctx "$ctx" '
    {
      first_ts: ([.[] | .timestamp // empty] | min),
      last_ts:  ([.[] | .timestamp // empty] | max),
      msgs:     ([.[] | select(.type == "user" or .type == "assistant")] | length),
      tokens:   ([.[]
                  | select(.type == "assistant")
                  | .message.usage // {}
                  | (.input_tokens // 0) + (.output_tokens // 0) + (.cache_creation_input_tokens // 0)
                 ] | add // 0),
      cwd:      ([.[] | .cwd // empty] | first // ""),
      first_prompt: ([.[]
                      | select(.type == "user")
                      | .message.content // ""
                      | (if type == "array" then (map(select(.type == "text")) | first.text // "") else . end)
                     ] | first // "")
    }
    | [
        $uuid, (.first_ts // ""), (.last_ts // ""), $ctx,
        ((.cwd // "") | split("/") | last // ""),
        (.msgs | tostring), (.tokens | tostring), (.cwd // ""),
        ((.first_prompt | tostring) | gsub("[\\n\\t]"; " ") | .[0:300])
      ] | @tsv
  ' "${files[@]}" 2>/dev/null
}

_klaude_sessions_resolve_uuid() {
  local target="$1"

  if [[ "$target" == "last" ]]; then
    local newest
    newest=$(_klaude_sessions_discover | xargs ls -1t 2>/dev/null | head -n1)
    [[ -z "$newest" ]] && { echo "No sessions found" >&2; return 1; }
    print -r -- "$newest"
    return 0
  fi

  local matches=() f
  while IFS= read -r f; do
    [[ "${f:t:r}" == "$target"* ]] && matches+=("$f")
  done < <(_klaude_sessions_discover)

  if (( ${#matches} == 0 )); then
    echo "No session matching: $target" >&2
    return 1
  elif (( ${#matches} > 1 )); then
    echo "Multiple sessions match prefix '$target':" >&2
    for f in "${matches[@]}"; do
      echo "  ${f:t:r}  (${f:h:t})" >&2
    done
    return 1
  fi

  print -r -- "${matches[1]}"
}

_klaude_sessions_collect_rows() {
  # Used by list and stats. Emits TSV rows with optional ctx/since filtering.
  local context_filter="$1" since_ts="$2"
  local f row rfirst rfirst_epoch rctx
  while IFS= read -r f; do
    row=$(_klaude_sessions_extract "$f") || continue
    [[ -z "$row" ]] && continue

    if [[ -n "$context_filter" ]]; then
      rctx=$(awk -F'\t' '{print $4}' <<< "$row")
      [[ "$rctx" != "$context_filter" ]] && continue
    fi

    if [[ -n "$since_ts" ]]; then
      rfirst=$(awk -F'\t' '{print $2}' <<< "$row")
      rfirst_epoch=$(_klaude_sessions_ts_to_epoch "$rfirst") || rfirst_epoch=0
      (( rfirst_epoch < since_ts )) && continue
    fi

    print -r -- "$row"
  done < <(_klaude_sessions_discover)
}

_klaude_sessions_list() {
  local context_filter="" since_ts="" limit=0 tsv=0 no_header=0
  while (( $# )); do
    case "$1" in
      --context)   context_filter="$2"; shift 2 ;;
      --since)     since_ts=$(_klaude_sessions_parse_since "$2") || return 1; shift 2 ;;
      --limit)     limit="$2"; shift 2 ;;
      --tsv)       tsv=1; shift ;;
      --no-header) no_header=1; shift ;;
      *) echo "Unknown flag: $1" >&2; return 1 ;;
    esac
  done

  local rows sorted now=$(date +%s)
  rows=$(_klaude_sessions_collect_rows "$context_filter" "$since_ts")
  [[ -z "$rows" ]] && return 0

  sorted=$(print -r -- "$rows" | sort -t$'\t' -k3 -r)
  (( limit > 0 )) && sorted=$(print -r -- "$sorted" | head -n "$limit")

  if (( tsv )); then
    if (( ! no_header )); then
      printf 'uuid\tfirst_ts\tlast_ts\tctx\tproject\tmsgs\ttokens\tcwd\tfirst_prompt\n'
    fi
    print -r -- "$sorted"
    return 0
  fi

  local cur_pwd cols prompt_width
  cur_pwd=$(pwd -P)
  cols=$(tput cols 2>/dev/null || echo 120)
  prompt_width=$((cols - 70))
  (( prompt_width < 20 )) && prompt_width=20

  local uuid first_ts last_ts ctx project msgs tokens cwd first_prompt
  local first_epoch last_epoch dur tokens_fmt time_fmt active pmt
  {
    printf 'TIME\tCTX\tPROJECT\tDUR\tMSGS\tTOKENS\tPROMPT\n'
    while IFS=$'\t' read -r uuid first_ts last_ts ctx project msgs tokens cwd first_prompt; do
      first_epoch=$(_klaude_sessions_ts_to_epoch "$first_ts") || first_epoch=0
      last_epoch=$(_klaude_sessions_ts_to_epoch "$last_ts")  || last_epoch=0
      dur=$((last_epoch - first_epoch))
      (( dur < 0 )) && dur=0
      tokens_fmt=$(_klaude_sessions_format_kn "${tokens:-0}")
      time_fmt=$(date -j -f "%s" "$first_epoch" +"%Y-%m-%d %H:%M" 2>/dev/null)
      active=""
      if [[ -n "$cwd" && "$cur_pwd" == "$cwd" ]] && (( now - last_epoch < 300 )); then
        active="*"
      fi
      pmt="${first_prompt:0:$prompt_width}"
      [[ ${#first_prompt} -gt $prompt_width ]] && pmt="${pmt}…"
      printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "${time_fmt}${active}" "$ctx" "$project" \
        "$(_klaude_sessions_format_dur $dur)" "$msgs" "$tokens_fmt" "$pmt"
    done <<< "$sorted"
  } | column -t -s$'\t'
}

_klaude_sessions_show() {
  local target="$1"
  [[ -z "$target" ]] && { echo "Usage: klaude-sessions show <uuid|prefix|last>" >&2; return 1; }

  local file
  file=$(_klaude_sessions_resolve_uuid "$target") || return 1

  local rendered
  rendered=$(jq -r '
    if .type == "user" then
      "\n[" + (.timestamp[:19]) + "] user\n" +
      ((.message.content // []) | (
        if type == "array" then
          (map(if .type == "text" then "> " + .text
               elif .type == "image" then "  [image]"
               else "  [" + (.type // "?") + "]" end) | join("\n"))
        else "> " + (. | tostring)
        end))
    elif .type == "assistant" then
      "\n[" + (.timestamp[:19]) + "] assistant (" + (.message.model // "?") + ")\n" +
      ((.message.content // []) | map(
        if .type == "text" then .text
        elif .type == "tool_use" then "  ⚙ " + (.name // "?") + ": " + ((.input // {}) | tostring | .[0:200])
        else "  [" + (.type // "?") + "]"
        end) | join("\n"))
    elif .type == "system" then
      "\n[" + ((.timestamp // "")[:19]) + "] system: " + (.subtype // .type)
    else
      empty
    end
  ' "$file" 2>/dev/null)

  if [[ -d "${file:r}/subagents" ]]; then
    local sub
    for sub in "${file:r}"/subagents/*.jsonl(N); do
      rendered+=$'\n\n--- subagent: '"${sub:t:r}"$' ---\n'
      rendered+=$(jq -r '
        if .type == "user" then
          "  [u] " + ((.timestamp // "")[:19]) + " " +
          ((.message.content // []) | (if type == "array" then (map(select(.type == "text") | .text) | join(" ")) else (. | tostring) end) | .[0:200])
        elif .type == "assistant" then
          "  [a] " + ((.timestamp // "")[:19]) + " " +
          ((.message.content // []) | map(if .type == "text" then .text elif .type == "tool_use" then "⚙" + (.name // "?") else "" end) | join(" ") | .[0:200])
        else empty end
      ' "$sub" 2>/dev/null)
    done
  fi

  if [[ -t 1 ]]; then
    print -r -- "$rendered" | less -R
  else
    print -r -- "$rendered"
  fi
}

_klaude_sessions_stats() {
  local by="" context_filter="" since_ts=""
  while (( $# )); do
    case "$1" in
      --by)      by="$2"; shift 2 ;;
      --context) context_filter="$2"; shift 2 ;;
      --since)   since_ts=$(_klaude_sessions_parse_since "$2") || return 1; shift 2 ;;
      *) echo "Unknown flag: $1" >&2; return 1 ;;
    esac
  done

  local rows
  rows=$(_klaude_sessions_collect_rows "$context_filter" "$since_ts")
  [[ -z "$rows" ]] && { echo "No sessions match filters."; return 0; }

  case "$by" in
    "")
      print -r -- "$rows" | awk -F'\t' '
        { sessions++; tokens+=$7; msgs+=$6; ctxc[$4]++; ctxt[$4]+=$7; ctxm[$4]+=$6 }
        END {
          printf "Total sessions: %d\nTotal messages:  %d\nTotal tokens:    %d\n\nBy context:\n", sessions, msgs, tokens
          for (c in ctxc) printf "  %-12s  %4d sessions  %8d msgs  %12d tokens\n", c, ctxc[c], ctxm[c], ctxt[c]
        }
      '
      ;;
    day)
      { printf 'DATE\tSESSIONS\tMSGS\tTOKENS\n'
        print -r -- "$rows" | awk -F'\t' '
          { d=substr($2,1,10); s[d]++; m[d]+=$6; t[d]+=$7 }
          END { for (d in s) printf "%s\t%d\t%d\t%d\n", d, s[d], m[d], t[d] }
        ' | sort -r
      } | column -t -s$'\t'
      ;;
    project)
      { printf 'PROJECT\tSESSIONS\tMSGS\tTOKENS\n'
        print -r -- "$rows" | awk -F'\t' '
          { s[$5]++; m[$5]+=$6; t[$5]+=$7 }
          END { for (p in s) printf "%s\t%d\t%d\t%d\n", p, s[p], m[p], t[p] }
        ' | sort -t$'\t' -k4 -rn
      } | column -t -s$'\t'
      ;;
    context)
      { printf 'CONTEXT\tSESSIONS\tMSGS\tTOKENS\n'
        print -r -- "$rows" | awk -F'\t' '
          { s[$4]++; m[$4]+=$6; t[$4]+=$7 }
          END { for (c in s) printf "%s\t%d\t%d\t%d\n", c, s[c], m[c], t[c] }
        ' | sort -t$'\t' -k4 -rn
      } | column -t -s$'\t'
      ;;
    tool)
      local f files
      _klaude_sessions_discover | while IFS= read -r f; do
        files=("$f")
        [[ -d "${f:r}/subagents" ]] && files+=("${f:r}"/subagents/*.jsonl(N))
        jq -r '. | select(.type == "assistant") | .message.content[]? | select(.type == "tool_use") | .name' "${files[@]}" 2>/dev/null
      done | sort | uniq -c | sort -rn | awk '{ printf "%-25s  %d\n", $2, $1 }'
      ;;
    model)
      local f
      _klaude_sessions_discover | while IFS= read -r f; do
        jq -r '. | select(.type == "assistant") | .message.model // empty' "$f" 2>/dev/null
      done | sort | uniq -c | sort -rn | awk '{ printf "%-30s  %d records\n", $2, $1 }'
      ;;
    *)
      echo "Invalid --by: $by (use day|project|tool|model|context)" >&2
      return 1
      ;;
  esac
}

_klaude_sessions_grep() {
  local pattern="" context_filter="" in_filter="all"
  while (( $# )); do
    case "$1" in
      --context) context_filter="$2"; shift 2 ;;
      --in)      in_filter="$2"; shift 2 ;;
      -*)        echo "Unknown flag: $1" >&2; return 1 ;;
      *)         pattern="$1"; shift ;;
    esac
  done
  [[ -z "$pattern" ]] && { echo "Usage: klaude-sessions grep <pattern> [--context X] [--in user|assistant|tool|all]" >&2; return 1; }

  local jq_filter
  case "$in_filter" in
    user)
      jq_filter='select(.type == "user") | .message.content // [] | (if type == "array" then map(select(.type == "text") | .text) | join("\n") else (. | tostring) end)'
      ;;
    assistant)
      jq_filter='select(.type == "assistant") | .message.content // [] | map(if .type == "text" then .text else "" end) | join("\n")'
      ;;
    tool)
      jq_filter='select(.type == "assistant") | .message.content // [] | map(if .type == "tool_use" then ((.name // "") + " " + ((.input // {}) | tostring)) else "" end) | join("\n")'
      ;;
    all)
      jq_filter='if .type == "user" then ((.message.content // []) | (if type == "array" then (map(select(.type == "text") | .text) | join("\n")) else "" end)) elif .type == "assistant" then ((.message.content // []) | map(if .type == "text" then .text elif .type == "tool_use" then ((.name // "") + " " + ((.input // {}) | tostring)) else "" end) | join("\n")) else empty end'
      ;;
    *)
      echo "Invalid --in: $in_filter (use user|assistant|tool|all)" >&2
      return 1
      ;;
  esac

  local f ctx match uuid first_ts first_epoch time_fmt line
  while IFS= read -r f; do
    ctx="${f:h:h:h:h:h:t}"
    [[ -n "$context_filter" && "$ctx" != "$context_filter" ]] && continue

    match=$(jq -r "$jq_filter" "$f" 2>/dev/null | grep -nE "$pattern" | head -3)
    [[ -z "$match" ]] && continue

    uuid="${f:t:r}"
    first_ts=$(jq -r 'select(.timestamp) | .timestamp' "$f" 2>/dev/null | head -1)
    first_epoch=$(_klaude_sessions_ts_to_epoch "$first_ts") || first_epoch=0
    time_fmt=$(date -j -f "%s" "$first_epoch" +"%Y-%m-%d %H:%M" 2>/dev/null)

    while IFS= read -r line; do
      printf "%s  %s  %s\n" "$time_fmt" "${uuid:0:8}" "${line:0:200}"
    done <<< "$match"
  done < <(_klaude_sessions_discover)
}

_klaude_sessions_delete() {
  local force=0 target=""
  while (( $# )); do
    case "$1" in
      --force) force=1; shift ;;
      *)       target="$1"; shift ;;
    esac
  done
  [[ -z "$target" ]] && { echo "Usage: klaude-sessions delete <uuid|prefix> [--force]" >&2; return 1; }

  local file
  file=$(_klaude_sessions_resolve_uuid "$target") || return 1

  echo "Will remove:"
  echo "  $file"
  [[ -d "${file:r}" ]] && echo "  ${file:r}/  (sibling dir)"

  if (( ! force )); then
    printf "Proceed? [y/N] "
    local reply
    read -r reply
    [[ "$reply" =~ ^[Yy]$ ]] || { echo "Aborted"; return 0; }
  fi

  rm -f "$file"
  [[ -d "${file:r}" ]] && rm -rf "${file:r}"
  echo "Removed."
}

_klaude_sessions_prune() {
  local force=0 older="" context_filter=""
  while (( $# )); do
    case "$1" in
      --older-than) older="$2"; shift 2 ;;
      --context)    context_filter="$2"; shift 2 ;;
      --force)      force=1; shift ;;
      *) echo "Unknown flag: $1" >&2; return 1 ;;
    esac
  done

  if [[ -z "$older" && -z "$context_filter" ]]; then
    echo "prune requires at least one filter (--older-than or --context)" >&2
    return 1
  fi

  local cutoff=0
  [[ -n "$older" ]] && { cutoff=$(_klaude_sessions_parse_since "$older") || return 1; }

  local victims=() f ctx first_ts first_epoch
  while IFS= read -r f; do
    ctx="${f:h:h:h:h:h:t}"
    [[ -n "$context_filter" && "$ctx" != "$context_filter" ]] && continue

    if (( cutoff > 0 )); then
      first_ts=$(jq -r 'select(.timestamp) | .timestamp' "$f" 2>/dev/null | head -1)
      first_epoch=$(_klaude_sessions_ts_to_epoch "$first_ts") || first_epoch=0
      (( first_epoch >= cutoff )) && continue
    fi

    victims+=("$f")
  done < <(_klaude_sessions_discover)

  if (( ${#victims} == 0 )); then
    echo "No sessions match filters."
    return 0
  fi

  echo "Will remove ${#victims} session(s):"
  for f in "${victims[@]}"; do
    echo "  ${f:t:r}  (${f:h:t})"
  done

  if (( ! force )); then
    printf "Proceed? [y/N] "
    local reply
    read -r reply
    [[ "$reply" =~ ^[Yy]$ ]] || { echo "Aborted"; return 0; }
  fi

  for f in "${victims[@]}"; do
    rm -f "$f"
    [[ -d "${f:r}" ]] && rm -rf "${f:r}"
  done
  echo "Removed ${#victims} session(s)."
}

_klaude_sessions_orphans() {
  local do_delete=0 force=0
  while (( $# )); do
    case "$1" in
      --delete) do_delete=1; shift ;;
      --force)  force=1; shift ;;
      *) echo "Unknown flag: $1" >&2; return 1 ;;
    esac
  done

  local orphans=() d
  for d in "$_KLAUDE_SESSIONS_ROOT"/*/tools/claude/projects/*/*(N/); do
    local uuid="${d:t}"
    [[ "$uuid" =~ "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$" ]] || continue
    [[ -f "${d}.jsonl" ]] && continue
    orphans+=("$d")
  done

  if (( ${#orphans} == 0 )); then
    echo "No orphan dirs found."
    return 0
  fi

  echo "Orphan directories:"
  local size
  for d in "${orphans[@]}"; do
    size=$(du -sh "$d" 2>/dev/null | awk '{print $1}')
    echo "  $d  ($size)"
  done

  if (( do_delete )); then
    if (( ! force )); then
      printf "Delete all? [y/N] "
      local reply
      read -r reply
      [[ "$reply" =~ ^[Yy]$ ]] || { echo "Aborted"; return 0; }
    fi
    for d in "${orphans[@]}"; do
      rm -rf "$d"
    done
    echo "Removed ${#orphans} orphan(s)."
  fi
}

klaude-sessions() {
  local cmd="$1"
  [[ -z "$cmd" ]] && { _klaude_sessions_help; return 0; }
  shift
  case "$cmd" in
    list)             _klaude_sessions_list    "$@" ;;
    show)             _klaude_sessions_show    "$@" ;;
    stats)            _klaude_sessions_stats   "$@" ;;
    grep)             _klaude_sessions_grep    "$@" ;;
    delete|rm)        _klaude_sessions_delete  "$@" ;;
    prune)            _klaude_sessions_prune   "$@" ;;
    orphans)          _klaude_sessions_orphans "$@" ;;
    help|-h|--help)   _klaude_sessions_help ;;
    *)
      echo "Unknown klaude-sessions command: $cmd" >&2
      _klaude_sessions_help
      return 1
      ;;
  esac
}

_klaude_sessions() {
  local -a subcmds
  subcmds=(
    'list:List sessions'
    'show:Render one session'
    'stats:Aggregate metrics'
    'grep:Search inside session content'
    'delete:Remove a session'
    'prune:Bulk-delete by filter'
    'orphans:Find/clean orphan dirs'
    'help:Show usage'
  )

  if (( CURRENT == 2 )); then
    _describe -t commands 'klaude-sessions command' subcmds
    return
  fi

  local -a contexts
  contexts=("$_KLAUDE_SESSIONS_ROOT"/*(N:t))
  contexts=(${contexts:#_*})

  case "${words[2]}" in
    list)
      case "${words[CURRENT-1]}" in
        --context) _describe -t contexts 'context' contexts ;;
        --since)   _values 'since' 'today' 'yesterday' '7d' '30d' ;;
        *)         _values 'flag' '--context' '--since' '--limit' '--tsv' '--no-header' ;;
      esac
      ;;
    show|delete|rm)
      local -a uuids
      uuids=( ${(f)"$(_klaude_sessions_discover 2>/dev/null | sed 's:.*/::; s:\.jsonl$::')"} )
      [[ "${words[2]}" == "show" ]] && uuids+=('last')
      _describe -t uuids 'session' uuids
      ;;
    stats)
      case "${words[CURRENT-1]}" in
        --by)      _values 'by' 'day' 'project' 'tool' 'model' 'context' ;;
        --context) _describe -t contexts 'context' contexts ;;
        --since)   _values 'since' 'today' 'yesterday' '7d' '30d' ;;
        *)         _values 'flag' '--by' '--context' '--since' ;;
      esac
      ;;
    grep)
      case "${words[CURRENT-1]}" in
        --in)      _values 'in' 'user' 'assistant' 'tool' 'all' ;;
        --context) _describe -t contexts 'context' contexts ;;
        *)         _values 'flag' '--context' '--in' ;;
      esac
      ;;
    prune)
      case "${words[CURRENT-1]}" in
        --older-than) _values 'when' '7d' '30d' '90d' ;;
        --context)    _describe -t contexts 'context' contexts ;;
        *)            _values 'flag' '--older-than' '--context' '--force' ;;
      esac
      ;;
    orphans)
      _values 'flag' '--delete' '--force'
      ;;
  esac
}
(( $+functions[compdef] )) && compdef _klaude_sessions klaude-sessions
