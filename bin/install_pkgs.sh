#!/bin/sh

DOTDIR=$(pwd)
#HOSTNAME=$(hostname)
HOSTNAME="T410"

HOSTFILE="$DOTDIR/pkg/$HOSTNAME.txt"
IGNORED_PKGS="vscode drm-61-kmod"

echo "📦 Installing packages..."

if [ -f "$HOSTFILE" ]; then
  echo "▶ Installing packages..."

  FILTER_CMD=""
  for pkg in $IGNORED_PKGS; do
    FILTER_CMD="$FILTER_CMD | grep -v -x $pkg"
  done

  CMD="grep -vE '^\s*#|^\s*$' \"$HOSTFILE\" $FILTER_CMD"
  PKGS=$(eval $CMD)

  if [ -n "$PKGS" ]; then
    sudo pkg install -y $PKGS
  else
    echo "ℹ️ Nenhum pacote para instalar após filtrar os ignorados."
  fi
fi

echo "✅ Package installation completed."
