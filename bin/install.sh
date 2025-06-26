#!/bin/sh

HOSTNAME=$(hostname)
DOTDIR=$(pwd)

# Detect if doas or sudo is available
if command -v doas >/dev/null 2>&1; then
  RUN_AS_ROOT="doas"
elif command -v sudo >/dev/null 2>&1; then
  RUN_AS_ROOT="sudo"
else
  echo "❌ Neither 'doas' nor 'sudo' found. Please run as root."
  exit 1
fi

echo "▶ Installing dotfiles for: $HOSTNAME"

# 🧱 Restore /etc
if [ -d "$DOTDIR/etc/$HOSTNAME" ]; then
  echo "▶ Copying files to /etc..."
  $RUN_AS_ROOT cp -v "$DOTDIR/etc/$HOSTNAME/"* /etc/
fi

# 🔧 Restore /boot
if [ -d "$DOTDIR/boot/$HOSTNAME" ]; then
  echo "▶ Copying files to /boot..."
  $RUN_AS_ROOT cp -v "$DOTDIR/boot/$HOSTNAME/"* /boot/
fi

# 🏠 Restore $HOME files
echo "▶ Copying files to ~"
cp -v "$DOTDIR/home/.shrc" "$HOME/"
cp -v "$DOTDIR/home/.login" "$HOME/"
cp -v "$DOTDIR/home/.profile" "$HOME/"

# 📁 Restore ~/.config
mkdir -p "$HOME/.config"

for dir in sway alacritty rofi; do
  if [ -d "$DOTDIR/home/.config/$dir" ]; then
    echo "▶ Copying ~/.config/$dir..."
    rm -rf "$HOME/.config/$dir"
    cp -r "$DOTDIR/home/.config/$dir" "$HOME/.config/"
  fi
done

# 📦 Install packages via pkg
PKG_FILE="$DOTDIR/pkg/$HOSTNAME.txt"
if [ -f "$PKG_FILE" ]; then
  echo "▶ Installing packages listed in $PKG_FILE..."
  $RUN_AS_ROOT pkg install -y $(cat "$PKG_FILE")
fi

echo "✅ Installation completed."
