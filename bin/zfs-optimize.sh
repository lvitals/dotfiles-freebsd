#!/bin/sh
# zfs-optimize.sh
# Description:
#   Applies fixed ZFS performance options to known datasets in a FreeBSD system.
#   Focused on reducing RAM/CPU usage for low-end hardware.

echo "🔍 Detecting all ZFS datasets..."
datasets=$(zfs list -H -o name)

if [ -z "$datasets" ]; then
    echo "⚠️ No ZFS datasets found."
    exit 1
fi

echo "✅ Found datasets:"
echo "$datasets"
echo

for ds in $datasets; do
    mountpoint=$(zfs get -H -o value mountpoint "$ds")

    # Skip datasets with unusable mountpoints
    if [ "$mountpoint" = "none" ] || [ "$mountpoint" = "legacy" ]; then
        echo "⚠️ Skipping dataset $ds with mountpoint=$mountpoint"
        continue
    fi

    echo "⚙️ Applying settings to dataset $ds mounted at $mountpoint"

    zfs set compression=off "$ds"
    zfs set atime=off "$ds"
    zfs set dedup=off "$ds"

    case "$mountpoint" in
        /tmp|/var/tmp)
            zfs set sync=disabled "$ds"
            ;;
        *)
            zfs set sync=standard "$ds"
            ;;
    esac
done

echo
echo "🔍 Current ZFS dataset properties after optimization:"
for ds in $datasets; do
    echo "Dataset: $ds"
    zfs get compression,atime,dedup,sync "$ds" | tail -n +2 | awk '{printf "  %s: %s\n", $2, $3}'
done

echo "✅ ZFS optimization complete."
