#!/usr/bin/env bash
set -euo pipefail

# === Konfig ===
VIVALDI_APP="${VIVALDI_APP:-/Applications/Vivaldi.app}"
VIVALDI_DIR="${VIVALDI_DIR:-$HOME/Library/Application Support/Vivaldi}"
OUT_DIR="$(pwd)"   # skriv filer i katalogen man står i

# === Avhengigheter ===
need() { command -v "$1" >/dev/null 2>&1 || { echo "Mangler avhengighet: $1"; exit 1; }; }
need bash
need jq

# === Slett og regenerer? ===
REGENERATE="${REGENERATE:-0}"
if [[ "${1:-}" == "--clean" ]]; then REGENERATE=1; fi
if [[ "$REGENERATE" == "1" ]]; then
  rm -f "$OUT_DIR"/vivaldi-*.sh 2>/dev/null || true
fi

# === Sjekker ===
if [[ ! -d "$VIVALDI_DIR" ]]; then
  echo "Fant ikke Vivaldi-data i: $VIVALDI_DIR"
  exit 1
fi

# === Finn profilmapper (POSIX/globbing, funker på macOS/BSD) ===
PROFILE_DIRS=()
# Default først hvis finnes
[[ -d "$VIVALDI_DIR/Default" ]] && PROFILE_DIRS+=("Default")
# Deretter Profile N
shopt -s nullglob
for p in "$VIVALDI_DIR"/Profile*; do
  [[ -d "$p" ]] && PROFILE_DIRS+=("$(basename "$p")")
done
shopt -u nullglob

if [[ ${#PROFILE_DIRS[@]} -eq 0 ]]; then
  echo "Fant ingen profilmapper i $VIVALDI_DIR (forventet 'Default' eller 'Profile N')"
  exit 1
fi

# === Hjelpere ===
slugify() {
  # Lowercase, bytt alt ikke-[a-z0-9] til bindestrek, trim bindestreker i kantene
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g'
}

profile_display_name() {
  local dir="$1"
  local prefs="$VIVALDI_DIR/$dir/Preferences"
  if [[ -f "$prefs" ]]; then
    # Les pene navn fra JSON; tom streng hvis ikke satt ennå
    jq -r 'try .profile.name // empty' "$prefs" 2>/dev/null || true
  else
    echo ""
  fi
}

# === Generer ett Raycast Script Command per profil ===
count=0
for d in "${PROFILE_DIRS[@]}"; do
  display="$(profile_display_name "$d")"
  if [[ -z "$display" ]]; then
    # Fallback: «Default» blir «Default», ellers bruk mappenavn
    if [[ "$d" == "Default" ]]; then display="Default"; else display="$d"; fi
  fi

  file_slug="$(slugify "$display")"
  out_file="$OUT_DIR/vivaldi-$file_slug.sh"

  cat > "$out_file" <<SCRIPT
#!/usr/bin/env bash
# metadata
# @raycast.schemaVersion 1
# @raycast.title Vivaldi – ${display}
# @raycast.mode silent
# @raycast.packageName Vivaldi Profiles
# @raycast.argument1 { "type": "text", "optional": true, "placeholder": "URL (valgfritt)" }

set -euo pipefail
VIVALDI_APP="${VIVALDI_APP}"
PROFILE_DIR="${d}"

if [[ -n "\${1:-}" ]]; then
  open -na "\$VIVALDI_APP" --args --profile-directory="\$PROFILE_DIR" "\$1"
else
  open -na "\$VIVALDI_APP" --args --profile-directory="\$PROFILE_DIR"
fi
SCRIPT

  chmod +x "$out_file"
  ((count++))
done

echo "Genererte $count Raycast-kommando(er) i: $OUT_DIR"
echo "Tips: Åpne Raycast → Extensions → Script Commands for å aktivere og ev. sette hotkeys."
