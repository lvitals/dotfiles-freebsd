#!/bin/sh

DOTDIR=$(pwd)
HOSTNAME=$(hostname)

echo "🖥️ System Configuration Installer"
echo "📂 Current hostname: $HOSTNAME"
echo

# Install global /etc files (not tied to any hostname)
GLOBAL_ETC_FILES="login.conf profile"
for file in $GLOBAL_ETC_FILES; do
  SRC="$DOTDIR/etc/$file"
  DEST="/etc/$file"
  if [ -f "$SRC" ]; then
    echo
    read -p "⚠️  Do you want to install global /etc/$file? [y/N] " CONFIRM
    if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
      cp -v "$SRC" "$DEST"
    else
      echo "⏭️  Skipped /etc/$file"
    fi
  fi
done

echo

# Function to install from system folders like /etc/<host> or /boot/<host>
install_system_config() {
  TYPE="$1"  # "etc" or "boot"
  echo "📂 Available $TYPE configurations:"

  for d in "$DOTDIR/$TYPE"/*/; do
    [ -d "$d" ] && echo " - $(basename "$d")"
  done

  echo
  read -p "🛠️  Enter the hostname folder from ./${TYPE}/ to install [default: $HOSTNAME]: " TARGET_HOST
  TARGET_HOST=${TARGET_HOST:-$HOSTNAME}

  SRC_DIR="$DOTDIR/$TYPE/$TARGET_HOST"
  if [ ! -d "$SRC_DIR" ]; then
    echo "❌ Directory $SRC_DIR not found."
    return
  fi

  echo
  read -p "⚠️  Confirm copying files from $SRC_DIR to /$TYPE/? [y/N] " CONFIRM
  if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
    echo "▶ Copying files to /$TYPE/..."
    cp -v "$SRC_DIR"/* "/$TYPE/"
    echo "✅ $TYPE configuration installed."
  else
    echo "⏭️  Skipped $TYPE installation."
  fi

  echo
}

# Install boot and etc configurations
install_system_config "boot"
install_system_config "etc"
