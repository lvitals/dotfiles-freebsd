#!/bin/sh

# ==== CONFIGURATION ====
ENABLE_AUDIO=true
ENABLE_VOLUME_BAR=true
ENABLE_DYNAMIC_VOLUME_ICON=true
ENABLE_BATTERY=true
ENABLE_BATTERY_BAR=true
ENABLE_DYNAMIC_BATTERY_ICON=true
ENABLE_NETWORK=true
INTERFACES="em0 wlan0"

# Date and Time Formats
DATE_FORMAT='+%Y-%m-%d'
TIME_FORMAT='+%H:%M:%S'

# ==== ICONS (requires Nerd Fonts) ====

# Static Power Icons (used if dynamic icon is disabled)
ICON_AC=""   # Bolt icon (plugged in)
ICON_BATT="󰁹" # Vertical battery icon (on battery)

# Dynamic Battery Icons
ICON_BATT_CHG="󰂄"   # Charging
ICON_BATT_100="󰁹"   # 100%
ICON_BATT_75="󰂂"    # ~75%
ICON_BATT_50="󰁾"    # ~50%
ICON_BATT_25="󰁻"    # ~25%
ICON_BATT_EMPTY="󰂃" # Empty / Alert

# Dynamic Volume Icons
ICON_VOL_HIGH="󰕾"   # High volume
ICON_VOL_MED="󰖀"    # Medium volume
ICON_VOL_LOW="󰕿"    # Low volume
ICON_VOL_MUTED="󰸈"  # Muted

# Date and Time Icons
ICON_CALENDAR="" # Calendar icon
ICON_CLOCK=""    # Clock icon

# Network Icons
ICON_WIFI=""
ICON_ETH=""
ICON_DISCONNECTED=""

# ==== COLORS - 0% to 100% levels ====
COLOR_RED="#ff0000"          # Red (0-15%)
COLOR_LIGHT_RED="#ff3333"    # Light Red (16-30%)
COLOR_YELLOW="#ffcc00"       # Yellow (31-50%)
COLOR_LIGHT_YELLOW="#ffff00" # Light Yellow (51-70%)
COLOR_MEDIUM_GREEN="#00cc66" # Medium Green (71-90%)
COLOR_LIGHT_GREEN="#00ff99"  # Light Green (91-100%)
COLOR_LEVEL_EMPTY="#888888"  # Gray for the empty parts

# ==== FUNCTIONS ====

get_audio_volume() {
    vol=$(sndioctl -n output.level 2>/dev/null | awk -F= '{
        percent = $1 * 100;
        rounded = int((percent + 5) / 10) * 10;
        rounded = rounded < 0 ? 0 : (rounded > 100 ? 100 : rounded);
        printf("%.0f", rounded);
    }')

    if [ -z "$vol" ]; then
        echo "N/A"
    else
        echo "$vol%"
    fi
}

get_battery_status() {
    batt=$(sysctl -n hw.acpi.battery.life 2>/dev/null || echo "N/A")

    if [ "$batt" = "N/A" ]; then
        echo "N/A"
    else
        echo "$batt%"
    fi
}

# Fallback function for static icon if dynamic is disabled
get_power_icon() {
    ac_status=$(sysctl -n hw.acpi.acline 2>/dev/null)
    if [ "$ac_status" = "1" ]; then
        echo "$ICON_AC "
    else
        echo "$ICON_BATT "
    fi
}

# Returns a dynamic volume icon based on the level and mute status
get_dynamic_volume_icon() {
    percent=$1
    mute_status=$(sndioctl -n output.mute 2>/dev/null)

    if [ "$mute_status" = "1" ] || [ "$percent" -eq 0 ]; then
        icon=$ICON_VOL_MUTED
    elif [ "$percent" -gt 66 ]; then
        icon=$ICON_VOL_HIGH
    elif [ "$percent" -gt 33 ]; then
        icon=$ICON_VOL_MED
    else
        icon=$ICON_VOL_LOW
    fi
    echo "$icon"
}

# Returns a dynamic battery icon based on the level and charging status
get_dynamic_battery_icon() {
    percent=$1
    ac_status=$2

    if [ "$ac_status" = "1" ]; then
        icon=$ICON_BATT_CHG
    elif [ "$percent" -gt 85 ]; then
        icon=$ICON_BATT_100
    elif [ "$percent" -gt 60 ]; then
        icon=$ICON_BATT_75
    elif [ "$percent" -gt 35 ]; then
        icon=$ICON_BATT_50
    elif [ "$percent" -gt 10 ]; then
        icon=$ICON_BATT_25
    else
        icon=$ICON_BATT_EMPTY
    fi
    echo "$icon"
}

draw_volume_bar() {
    percent=$(echo "$1" | sed 's/<[^>]*>//g' | tr -d '%' | cut -d. -f1)
    [ -z "$percent" ] && percent=0

    if [ "$percent" -eq 0 ]; then
        echo "<span color=\"$COLOR_LEVEL_EMPTY\">▮▮▮▮▮▮▮▮▮▮</span>"
    else
        filled=$((percent / 10))
        [ "$filled" -eq 0 ] && [ "$percent" -gt 0 ] && filled=1
        empty=$((10 - filled))

        color1="$COLOR_LIGHT_GREEN"
        color2="$COLOR_LIGHT_GREEN"
        color3="$COLOR_MEDIUM_GREEN"
        color4="$COLOR_MEDIUM_GREEN"
        color5="$COLOR_LIGHT_YELLOW"
        color6="$COLOR_LIGHT_YELLOW"
        color7="$COLOR_YELLOW"
        color8="$COLOR_YELLOW"
        color9="$COLOR_LIGHT_RED"
        color10="$COLOR_RED"

        bar_filled=""
        i=1
        while [ $i -le $filled ]; do
            eval "color=\"\$color$i\""
            bar_filled="${bar_filled}<span color=\"${color}\">▮</span>"
            i=$((i + 1))
        done

        bar_empty=""
        j=0
        while [ $j -lt $empty ]; do
            bar_empty="${bar_empty}<span color=\"$COLOR_LEVEL_EMPTY\">▮</span>"
            j=$((j + 1))
        done

        echo "$bar_filled$bar_empty"
    fi
}

draw_battery_bar() {
    percent=$(echo "$1" | sed 's/<[^>]*>//g' | tr -d '%' | cut -d. -f1)
    [ -z "$percent" ] && percent=0

    if [ "$percent" -eq 0 ]; then
        echo "<span color=\"$COLOR_LEVEL_EMPTY\">▮▮▮▮▮▮▮▮▮▮</span>"
    else
        filled=$((percent / 10))
        [ "$filled" -eq 0 ] && [ "$percent" -gt 0 ] && filled=1
        empty=$((10 - filled))

        color1="$COLOR_RED"
        color2="$COLOR_LIGHT_RED"
        color3="$COLOR_YELLOW"
        color4="$COLOR_YELLOW"
        color5="$COLOR_LIGHT_YELLOW"
        color6="$COLOR_LIGHT_YELLOW"
        color7="$COLOR_MEDIUM_GREEN"
        color8="$COLOR_MEDIUM_GREEN"
        color9="$COLOR_LIGHT_GREEN"
        color10="$COLOR_LIGHT_GREEN"

        bar_filled=""
        i=1
        while [ $i -le $filled ]; do
            eval "color=\"\$color$i\""
            bar_filled="${bar_filled}<span color=\"${color}\">▮</span>"
            i=$((i + 1))
        done

        bar_empty=""
        j=0
        while [ $j -lt $empty ]; do
            bar_empty="${bar_empty}<span color=\"$COLOR_LEVEL_EMPTY\">▮</span>"
            j=$((j + 1))
        done

        echo "$bar_filled$bar_empty"
    fi
}

# Retrieves and formats the current network status.
get_network_display() {
    local iface=""
    local ip=""
    local ssid=""
    local net_info=""

    # Loop through the specified network interfaces.
    for i in $INTERFACES; do
        # Get the IP address and status of the current interface.
        # Errors are redirected to /dev/null to avoid clutter if an interface doesn't exist.
        ip_addr=$(ifconfig "$i" 2>/dev/null | awk '/inet /{print $2}')
        status=$(ifconfig "$i" 2>/dev/null | awk '/status:/{print $2}')

        # Check if the interface has an IP and is active.
        # Different systems use different status keywords (e.g., "active", "UP", "associated").
        if [ -n "$ip_addr" ] && \
           ( [ "$status" = "active" ] || [ "$status" = "UP" ] || [ "$status" = "RUNNING" ] || [ "$status" = "associated" ] ); then
            iface=$i
            ip=$ip_addr
            # Break the loop as soon as an active interface is found.
            break
        fi
    done

    # Format the output string based on the active interface type.
    if [ "$iface" = "wlan0" ]; then
        # If it's a Wi-Fi interface, get the SSID.
        ssid=$(ifconfig wlan0 2>/dev/null | awk '/ssid/ {print $2; exit}')
        net_info="$ICON_WIFI   Wi-Fi: ($ssid) $ip"
    elif [ -n "$iface" ]; then
        # If it's a wired (Ethernet) interface.
        net_info="$ICON_ETH   Eth: $ip"
    else
        # If no active interface was found.
        net_info="$ICON_DISCONNECTED   Offline"
    fi

    echo "$net_info"
}


get_datetime_display() {
    date_str="$ICON_CALENDAR  $(date "$DATE_FORMAT")"
    time_str="$ICON_CLOCK  $(date "$TIME_FORMAT")"

    echo "$date_str  $time_str"
}

# ==== MAIN LOOP ====

while true; do
    line=""

    if [ "$ENABLE_AUDIO" = true ]; then
        vol_str=$(get_audio_volume)
        vol_percent=$(echo "$vol_str" | tr -d '%')
        vol_display=""

        if [ "$ENABLE_DYNAMIC_VOLUME_ICON" = true ]; then
            vol_icon=$(get_dynamic_volume_icon "$vol_percent")
            vol_display="$vol_icon $vol_str"
        else
            vol_display="$vol_str"
        fi

        if [ "$ENABLE_VOLUME_BAR" = true ]; then
            vol_bar=$(draw_volume_bar "$vol_str")
            line="$line | Vol: $vol_display $vol_bar"
        else
            line="$line | Vol: $vol_display"
        fi
    fi

    if [ "$ENABLE_BATTERY" = true ]; then
        batt_str=$(get_battery_status)
        batt_percent=$(echo "$batt_str" | tr -d '%')
        ac_status=$(sysctl -n hw.acpi.acline 2>/dev/null)
        batt_display=""

        if [ "$ENABLE_DYNAMIC_BATTERY_ICON" = true ]; then
            batt_icon=$(get_dynamic_battery_icon "$batt_percent" "$ac_status")
            batt_display="$batt_icon $batt_str"
        else
            # Fallback to the old static icon
            batt_icon=$(get_power_icon)
            batt_display="$batt_icon$batt_str"
        fi

        if [ "$ENABLE_BATTERY_BAR" = true ]; then
            batt_bar=$(draw_battery_bar "$batt_str")
            line="$line | Bat: $batt_display $batt_bar"
        else
            line="$line | Bat: $batt_display"
        fi
    fi

    if [ "$ENABLE_NETWORK" = true ]; then
        # Call the new function to get the network status display
        network_display=$(get_network_display)
        line="$line | $network_display"
    fi

    datetime_display=$(get_datetime_display)
    line="$line | $datetime_display"

    # Print the final status line, removing the leading separator
    echo "${line# | }"
    sleep 1
done