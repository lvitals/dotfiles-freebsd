#!/bin/sh

HINTS="/boot/device.hints"
TMP="/tmp/hdaa_scan.$$"
touch "$TMP"

echo "🔎 Searching for dev.hdaa codecs..."

for DEV in $(sysctl -Na | grep -E '^dev\.hdaa\.[0-9]+\.nid[0-9]+_config$' | sed -E 's/dev\.hdaa\.([0-9]+)\..*/\1/' | sort -u); do
    echo "🎧 Analyzing dev.hdaa.$DEV..."

    sysctl -a | grep "^dev.hdaa.$DEV.nid[0-9]\+_config" > "$TMP"

    SPEAKER_LINE=$(grep -i 'device=Speaker' "$TMP" | grep 'conn=Fixed' | head -n1)
    HPHONE_LINE=$(grep -i 'device=Headphones' "$TMP" | grep 'conn=Jack' | head -n1)

    SPEAKER_NID=$(echo "$SPEAKER_LINE" | sed -E "s/.*nid([0-9]+)_config:.*/\1/")
    HPHONE_NID=$(echo "$HPHONE_LINE" | sed -E "s/.*nid([0-9]+)_config:.*/\1/")

    SPEAKER_HEX=$(echo "$SPEAKER_LINE" | awk '{print $2}')
    HPHONE_HEX=$(echo "$HPHONE_LINE" | awk '{print $2}')

    if [ -z "$SPEAKER_NID" ] || [ -z "$HPHONE_NID" ]; then
        echo "⚠️ Speaker or Headphones not found on dev.hdaa.$DEV"
        continue
    fi

    echo "✅ Found: Speaker (nid=$SPEAKER_NID, hex=$SPEAKER_HEX), Headphones (nid=$HPHONE_NID, hex=$HPHONE_HEX)"

    # Remove old entries
    sed -i '' "/^hint.hdaa.$DEV.nid${SPEAKER_NID}.config/d" "$HINTS"
    sed -i '' "/^hint.hdaa.$DEV.nid${HPHONE_NID}.config/d" "$HINTS"

    # Add new entries
    echo "hint.hdaa.$DEV.nid${SPEAKER_NID}.config=\"$SPEAKER_HEX\"" >> "$HINTS"
    echo "hint.hdaa.$DEV.nid${HPHONE_NID}.config=\"$HPHONE_HEX\"" >> "$HINTS"

    # Apply reconfiguration
    sysctl dev.hdaa.$DEV.reconfig=1
done

rm -f "$TMP"
echo "✅ Configuration applied. Please reboot to make it persistent."
