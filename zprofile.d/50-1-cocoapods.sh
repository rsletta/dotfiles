# Set homebrew ruby path
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

# Keep user-installed gems (including CocoaPods) on PATH without pinning Ruby.
if command -v gem >/dev/null 2>&1; then
  export GEM_HOME="$(gem env user_gemhome)"
  export PATH="$GEM_HOME/bin:$PATH"
fi
