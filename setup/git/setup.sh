#!/usr/bin/env bash
set -euo pipefail

# Git identity lives in ~/.gitconfig.local, included from the repo-managed
# ~/.gitconfig so both profiles share the same signing setup: personal
# machines get the personal identity written automatically, work machines are
# asked for the corporate one.

LOCAL_CONFIG="$HOME/.gitconfig.local"
PROFILE="$(cat "$HOME/.dotfiles-profile" 2>/dev/null || echo personal)"

if [[ -f "$LOCAL_CONFIG" ]]; then
  echo "ℹ️  Git identity already configured in $LOCAL_CONFIG, skipping"
  exit 0
fi

if [[ "$PROFILE" == "personal" ]]; then
  GIT_NAME="rubasace"
  GIT_EMAIL="ruben.pahino.verdugo@gmail.com"
else
  if [[ ! -t 0 ]]; then
    echo "⚠️  Work profile has no git identity yet; run setup/git/setup.sh from a terminal"
    exit 0
  fi
  GIT_NAME=""
  GIT_EMAIL=""
  while [[ -z "$GIT_NAME" ]]; do
    read -rp "Corporate git name: " GIT_NAME
  done
  while [[ -z "$GIT_EMAIL" ]]; do
    read -rp "Corporate git email: " GIT_EMAIL
  done
fi

cat > "$LOCAL_CONFIG" <<EOF
[user]
	name = ${GIT_NAME}
	email = ${GIT_EMAIL}
EOF

# Work signatures verify against a machine-local signers file so the corporate
# identity never lands in the repo-managed allowed_signers
if [[ "$PROFILE" == "work" ]]; then
  cat >> "$LOCAL_CONFIG" <<'EOF'
[gpg "ssh"]
	allowedSignersFile = ~/.ssh/allowed_signers_local
EOF
fi

echo "✅ Git identity written to $LOCAL_CONFIG (${GIT_NAME} <${GIT_EMAIL}>)"
