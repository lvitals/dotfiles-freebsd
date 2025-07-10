#!/bin/sh

HOSTNAME=$(hostname)
DOTDIR=$(pwd)
RUN_AS_ROOT=""

usage() {
  echo "Usage: $0 [all|etc|boot|home|config|pkgs]"
  echo "If no argument is given, everything will be restored."
  exit 1
}

# Detect doas or sudo
if command -v doas >/dev/null 2>&1; then
  RUN_AS_ROOT="doas"
elif command -v sudo >/dev/null 2>&1; then
  RUN_AS_ROOT="sudo"
else
  echo "❌ Neither 'doas' nor 'sudo' found. Please run as root."
  exit 1
fi

# Check if hostname exists in any of the folders
if [ ! -d "$DOTDIR/etc/$HOSTNAME" ] && \
   [ ! -d "$DOTDIR/boot/$HOSTNAME" ] && \
   [ ! -f "$DOTDIR/pkg/$HOSTNAME.txt" ]; then
  echo "❌ Hostname '$HOSTNAME' not found in etc/, boot/, or pkg/"
  echo "🧭 Available hostnames:"
  echo "  etc/:  $(ls -1 $DOTDIR/etc 2>/dev/null | xargs)"
  echo "  boot/: $(ls -1 $DOTDIR/boot 2>/dev/null | xargs)"
  echo "  pkg/:  $(ls -1 $DOTDIR/pkg 2>/dev/null | sed 's/\.txt$//' | xargs)"
  echo "Please check or specify the correct hostname."
  exit 1
fi

# Argument parsing
RESTORE_ALL=true
RESTORE_ETC=false
RESTORE_BOOT=false
RESTORE_HOME=false
RESTORE_CONFIG=false
INSTALL_PKGS=false

for arg in "$@"; do
  case "$arg" in
    etc) RESTORE_ETC=true; RESTORE_ALL=false ;;
    boot) RESTORE_BOOT=true; RESTORE_ALL=false ;;
    home) RESTORE_HOME=true; RESTORE_ALL=false ;;
    config) RESTORE_CONFIG=true; RESTORE_ALL=false ;;
    pkgs) INSTALL_PKGS=true; RESTORE_ALL=false ;;
    all) RESTORE_ALL=true ;;
    *) usage ;;
  esac
done

echo "▶ Installing dotfiles for: $HOSTNAME"

# 🧱 Restore /etc
if $RESTORE_ALL || $RESTORE_ETC; then
  if [ -d "$DOTDIR/etc/$HOSTNAME" ]; then
    echo "▶ Copying files to /etc..."
    $RUN_AS_ROOT cp -v "$DOTDIR/etc/$HOSTNAME/"* /etc/
  fi
fi

# 🔧 Restore /boot
if $RESTORE_ALL || $RESTORE_BOOT; then
  if [ -d "$DOTDIR/boot/$HOSTNAME" ]; then
    echo "▶ Copying files to /boot..."
    $RUN_AS_ROOT cp -v "$DOTDIR/boot/$HOSTNAME/"* /boot/
  fi
fi

# 🏠 Restore home files
if $RESTORE_ALL || $RESTORE_HOME; then
  echo "▶ Copying files to ~"
  cp -v "$DOTDIR/home/.shrc" "$HOME/"
  cp -v "$DOTDIR/home/.login" "$HOME/"
  cp -v "$DOTDIR/home/.profile" "$HOME/"
fi

# 📁 Restore ~/.config
if $RESTORE_ALL || $RESTORE_CONFIG; then
  mkdir -p "$HOME/.config"
  for dir in sway foot rofi; do
    if [ -d "$DOTDIR/home/.config/$dir" ]; then
      echo "▶ Copying ~/.config/$dir..."
      rm -rf "$HOME/.config/$dir"
      cp -r "$DOTDIR/home/.config/$dir" "$HOME/.config/"
    fi
  done
fi

# 📦 Install packages via bin/install_pkgs.sh
if $RESTORE_ALL || $INSTALL_PKGS; then
  PKG_FILE="$DOTDIR/pkg/$HOSTNAME.txt"
  if [ -f "$PKG_FILE" ]; then
    if [ -x "$DOTDIR/bin/install_pkgs.sh" ]; then
      echo "▶ Installing packages using bin/install_pkgs.sh..."
      "$DOTDIR/bin/install_pkgs.sh" "$PKG_FILE"
    else
      echo "❌ bin/install_pkgs.sh not found or not executable."
      exit 1
    fi
  fi
fi

echo "✅ Installation complete."
