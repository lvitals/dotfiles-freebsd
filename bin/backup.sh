#!/bin/sh

HOSTNAME=$(hostname)
DOTDIR=$(pwd)

# Backups /etc
mkdir -p "$DOTDIR/etc/$HOSTNAME"
cp -v /etc/rc.conf "$DOTDIR/etc/$HOSTNAME/"
cp -v /etc/sysctl.conf "$DOTDIR/etc/$HOSTNAME/"
cp -v /etc/login.conf "$DOTDIR/etc/$HOSTNAME/"

# Backups /boot
mkdir -p "$DOTDIR/boot/$HOSTNAME"
cp -v /boot/loader.conf "$DOTDIR/boot/$HOSTNAME/"
cp -v /boot/device.hints "$DOTDIR/boot/$HOSTNAME/"

# Backups /home
mkdir -p "$DOTDIR/home/"
cp -v "$HOME/.shrc" "$DOTDIR/home/"
cp -v "$HOME/.login" "$DOTDIR/home/"
cp -v "$HOME/.profile" "$DOTDIR/home/"

# Backups /home/.config
mkdir -p "$DOTDIR/home/.config"
cp -r "$HOME/.config/sway" "$DOTDIR/home/.config/"
cp -r "$HOME/.config/foot" "$DOTDIR/home/.config/"
cp -r "$HOME/.config/rofi" "$DOTDIR/home/.config/"

mkdir -p "$DOTDIR/pkg/"
pkg query '%n' > pkg/T410.txt
