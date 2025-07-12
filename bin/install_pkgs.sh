#!/bin/sh

DOTDIR=$(pwd)
PKGDIR="$DOTDIR/pkg"
IGNORED_PKGS="vscode drm-61-kmod"

echo "📦 Available host configurations:"
echo

# List available host folders under ./pkg/
for d in "$PKGDIR"/*/; do
  [ -d "$d" ] && echo " - $(basename "$d")"
done

echo
# Ask the user which host to install packages for
printf "🔧 Enter the hostname to install packages from: "
read HOSTNAME

HOSTFILE="$PKGDIR/$HOSTNAME/pkglist.txt"

if [ ! -f "$HOSTFILE" ]; then
  echo "❌ Package list not found for hostname: $HOSTNAME"
  exit 1
fi

echo "▶ Installing packages from $HOSTFILE..."

# Build filter to exclude ignored packages
FILTER_CMD=""
for pkg in $IGNORED_PKGS; do
  FILTER_CMD="$FILTER_CMD | grep -v -x $pkg"
done

# Remove comments and empty lines, then apply filter
CMD="grep -vE '^\s*#|^\s*$' \"$HOSTFILE\" $FILTER_CMD"
PKGS=$(eval $CMD)

if [ -n "$PKGS" ]; then
  pkg install -y $PKGS
else
  echo "ℹ️ No packages to install after filtering ignored ones."
fi

echo "✅ Package installation completed."
