#!/bin/sh

HOSTNAME=$(hostname)
DOTDIR=$(pwd)
OUTPUT_DIR="$DOTDIR/info"
OUTPUT_FILE="$OUTPUT_DIR/info-hw-$HOSTNAME.txt"
TMP_FILE="$OUTPUT_DIR/info-hw-$HOSTNAME.tmp"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "🔍 Generating hardware report for $HOSTNAME..."
printf "Hardware Report - %s\n" "$HOSTNAME" > "$TMP_FILE"
printf "Generated on: %s\n" "$(date)" >> "$TMP_FILE"
printf -- "------------------------------------------\n\n" >> "$TMP_FILE"

# Hostname (mascarado)
printf "[ Hostname ]\n" >> "$TMP_FILE"
printf "HOSTNAME_REDACTED\n\n" >> "$TMP_FILE"

# System info (sem mascarar, pode conter hostname)
printf "[ System Information ]\n" >> "$TMP_FILE"
uname -a >> "$TMP_FILE"
printf "\n" >> "$TMP_FILE"

# CPU info
printf "[ CPU ]\n" >> "$TMP_FILE"
sysctl -n hw.model | while read -r line; do printf "%s\n" "$line"; done >> "$TMP_FILE"
sysctl -n hw.ncpu | awk '{print "Cores:", $1}' >> "$TMP_FILE"
printf "\n" >> "$TMP_FILE"

# Memory
printf "[ Memory ]\n" >> "$TMP_FILE"
MEM_BYTES=$(sysctl -n hw.physmem)
MEM_MB=$((MEM_BYTES / 1024 / 1024))
printf "Total RAM: %s MB\n\n" "$MEM_MB" >> "$TMP_FILE"

# Disks
printf "[ Disks ]\n" >> "$TMP_FILE"
geom disk list >> "$TMP_FILE"
printf "\n" >> "$TMP_FILE"

# Filesystems
printf "[ Filesystems ]\n" >> "$TMP_FILE"
df -h >> "$TMP_FILE"
printf "\n" >> "$TMP_FILE"

# Network interfaces
printf "[ Network Interfaces ]\n" >> "$TMP_FILE"
ifconfig -a >> "$TMP_FILE"
printf "\n" >> "$TMP_FILE"

# PCI devices
printf "[ PCI Devices ]\n" >> "$TMP_FILE"
pciconf -lv >> "$TMP_FILE"
printf "\n" >> "$TMP_FILE"

# USB devices
printf "[ USB Devices ]\n" >> "$TMP_FILE"
usbconfig >> "$TMP_FILE"
printf "\n" >> "$TMP_FILE"

# Loaded kernel modules
printf "[ Kernel Modules ]\n" >> "$TMP_FILE"
kldstat >> "$TMP_FILE"
printf "\n" >> "$TMP_FILE"

# Mask datas
sed -e 's/ether [0-9a-f:]\{17\}/ether XX:XX:XX:XX:XX:XX/g' \
    -e 's/\([[:space:]]inet \)[0-9]\{1,3\}\(\.[0-9]\{1,3\}\)\{3\}/\1XXX.XXX.XXX.XXX/g' \
    -e 's/\([[:space:]]inet6 \)[0-9a-f:]\{2,\}/\1XXX:XXX:XXX:XXX:XXX/g' \
    -e 's/\(ssid \).*/\1SSID_REDACTED/gI' \
    -e "s/$HOSTNAME/HOSTNAME_REDACTED/g" \
    "$TMP_FILE" > "$OUTPUT_FILE"

rm "$TMP_FILE"

printf "✅ Report saved to: %s\n" "$OUTPUT_FILE"
