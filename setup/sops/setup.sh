#!/usr/bin/env bash
set -euo pipefail

KEYS_DIR="$HOME/Library/Application Support/sops/age"
KEYS_FILE="$KEYS_DIR/keys.txt"

echo "🔑 SOPS (age) setup starting..."

if [[ ! -f "$KEYS_FILE" ]]; then
  echo "Creating age key for sops"
  mkdir -p "$KEYS_DIR"
  chmod 700 "$KEYS_DIR"
  age-keygen -o "$KEYS_FILE"
  chmod 600 "$KEYS_FILE"
else
  echo "age key already exists, skipping generation"
fi

echo ""
echo "sops age public key (add as recipient in each repo's .sops.yaml, then run 'sops updatekeys'):"
grep "public key:" "$KEYS_FILE" | sed 's/.*public key: //'
echo ""

echo "✅ SOPS setup complete"
