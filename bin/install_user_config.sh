#!/bin/sh

DOTDIR=$(pwd)

echo "📁 Installing user configuration files..."
echo

read -p "🏠 Do you want to install files from ./home/ to your user directory? [y/N] " INSTALL_HOME

if [ "$INSTALL_HOME" = "y" ] || [ "$INSTALL_HOME" = "Y" ]; then
  echo "▶ Copying files to $HOME..."

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

  echo "✅ User configuration installed successfully."
else
  echo "⏭️  Skipped user configuration."
fi
