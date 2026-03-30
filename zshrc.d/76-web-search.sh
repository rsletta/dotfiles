# Terminal search via ddgr + w3m. noglob prevents ? expansion in queries.
# Press 'o' inside w3m to open the current page in the default GUI browser.
# Optionally prefix with an engine name: wtf google how do i do x
# youtube and devdocs open directly in the GUI browser; all others use w3m.
function _wtf() {
  local -A bangs=(
    google    g
    github    gh
    youtube   yt
    devdocs   dd
    reddit    r
    wikipedia w
    aws       aws
    azure     azure
    msdocs    msdocs
    terraform tmg
    k8s       k8s
    dhdocs    dhdocs
  )
  local -A browser_direct=(youtube 1 devdocs 1)

  if [[ -n "${bangs[$1]}" ]]; then
    local engine="$1" bang="${bangs[$1]}"
    shift
    if [[ -n "${browser_direct[$engine]}" ]]; then
      ddgr --gb "!${bang} $*"
    else
      ddgr --url-handler w3m "!${bang} $*"
    fi
  else
    ddgr --url-handler w3m "$@"
  fi
}
alias wtf='noglob _wtf'

function _wtf_completion() {
  _values 'search engine' \
    'google[Google]' \
    'youtube[YouTube — opens in browser]' \
    'github[GitHub]' \
    'devdocs[DevDocs — opens in browser]' \
    'reddit[Reddit]' \
    'wikipedia[Wikipedia]' \
    'aws[AWS Docs]' \
    'azure[Azure Docs]' \
    'msdocs[Microsoft Docs / learn.microsoft.com]' \
    'terraform[Terraform Module Registry]' \
    'k8s[Kubernetes Docs]' \
    'dhdocs[Docker Docs]'
}
compdef _wtf_completion _wtf
compdef _wtf_completion wtf

# Open a URL in the default GUI browser
function browse() {
  open "$1"
}
