#!/usr/bin/env bash
# alvify.sh – A/a → "Alv" + interaktiv avslutning med q/Q
#   SKIP_CHARS  = bokstaver som gjør at første A/a hoppes over (default "rRtT")

SKIP_CHARS=${SKIP_CHARS:-"rRtT"}

alvify() {                                  # behandle én tekstlinje
  local text=$1
  awk -v skip="[$SKIP_CHARS]" '
  function replace(w,   i,ch,nxtChar,firstPos,chosenPos) {
      for (i = 1; i <= length(w); i++) {
          ch = substr(w,i,1)
          if (ch == "A" || ch == "a") {
              if (!firstPos) firstPos = i
              nxtChar = (i < length(w) ? substr(w,i+1,1) : "")
              if (nxtChar !~ skip) { chosenPos = i; break }
          }
      }
      if (!chosenPos) chosenPos = firstPos
      if (!chosenPos) return w
      return substr(w,1,chosenPos-1)"Alv"substr(w,chosenPos+1)
  }
  { for (i=1;i<=NF;i++) $i=replace($i); print }
  ' <<< "$text"
}

# --- 1) Eventuelle argumenter behandles først ------------------------------
if [[ $# -gt 0 ]]; then
  alvify "$*"
fi

# --- 2) Les STDIN linje for linje – avslutt på q/Q -------------------------
while IFS= read -r line; do
  [[ $line == [qQ] ]] && exit 0            # “q” eller “Q” på blank linje → ferdig
  alvify "$line"
done

