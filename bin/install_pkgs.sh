#!/bin/sh

DOTDIR=$(pwd)
HOSTNAME=$(hostname)

HOSTFILE="$DOTDIR/pkg/$HOSTNAME.txt"

echo "📦 Installing packages..."

if [ -f "$HOSTFILE" ]; then
  echo "▶ Installing packages specific to $HOSTNAME..."
  sudo pkg install -y $(grep -vE '^\s*#|^\s*$' "$HOSTFILE")
fi

echo "✅ Package installation completed."
