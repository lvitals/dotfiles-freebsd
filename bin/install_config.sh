#!/bin/sh

DOTDIR=$(pwd)
HOSTNAME=$(hostname)

echo "📂 Current hostname: $HOSTNAME"
echo

# Ask to restore home configs
read -p "🏠 Do you want to install user config files from ./home/? [y/N] " INSTALL_HOME

if [ "$INSTALL_HOME" = "y" ] || [ "$INSTALL_HOME" = "Y" ]; then
  echo "▶ Installing files from ./home/ to $HOME..."
  
  for file in .shrc .login .profile .login_conf; do
    SRC="$DOTDIR/home/$file"
    if [ -f "$SRC" ]; then
      cp -v "$SRC" "$HOME/"
    fi
  done

  CONFIG_DIR="$DOTDIR/home/.config"
  if [ -d "$CONFIG_DIR" ]; then
    for d in sway foot rofi; do
      if [ -d "$CONFIG_DIR/$d" ]; then
        mkdir -p "$HOME/.config"
        cp -rv "$CONFIG_DIR/$d" "$HOME/.config/"
      fi
    done
  fi
  echo "✅ User config installation completed."
else
  echo "⏭️  Skipped user config files."
fi

echo
# Install global etc files (login.conf, profile)
GLOBAL_ETC_FILES="login.conf profile"
for file in $GLOBAL_ETC_FILES; do
  SRC="$DOTDIR/etc/$file"
  DEST="/etc/$file"
  if [ -f "$SRC" ]; then
    echo
    read -p "⚠️  Do you want to install global /etc/$file? [y/N] " CONFIRM_GLOBAL
    if [ "$CONFIRM_GLOBAL" = "y" ] || [ "$CONFIRM_GLOBAL" = "Y" ]; then
      cp -v "$SRC" "$DEST"
    else
      echo "⏭️  Skipped /etc/$file"
    fi
  fi
done

echo
# Function to install from system folders (/etc/<host> or /boot/<host>)
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
    echo "✅ $TYPE installation completed."
  else
    echo "⏭️  Skipped $TYPE installation."
  fi
  echo
}

# Ask for /boot/<host>
install_system_config "boot"

# Ask for /etc/<host>
install_system_config "etc"
