#!/bin/sh

# ==== CONFIGURAÇÃO ====
ENABLE_AUDIO=true
ENABLE_VOLUME_BAR=true
ENABLE_BATTERY=true
ENABLE_BATTERY_BAR=true
ENABLE_NETWORK=true
ENABLE_WORKSPACE=true
INTERFACES="em0 wlan0"

# Cores - Níveis de 0% a 100%
COLOR_RED="#ff0000"          # Vermelho (0-15%)
COLOR_LIGHT_RED="#ff3333"    # Vermelho claro (16-30%)
COLOR_YELLOW="#ffcc00"       # Amarelo (31-50%)
COLOR_LIGHT_YELLOW="#ffff00" # Amarelo claro (51-70%)
COLOR_MEDIUM_GREEN="#00cc66" # Verde médio (71-90%)
COLOR_LIGHT_GREEN="#00ff99"  # Verde claro (91-100%)
COLOR_LEVEL_EMPTY="#888888"  # Cinza para as partes vazias (nova variável)

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

draw_volume_bar() {
    percent=$(echo "$1" | sed 's/<[^>]*>//g' | tr -d '%' | cut -d. -f1)
    [ -z "$percent" ] && percent=0
    
    if [ "$percent" -eq 0 ]; then
        echo "<span color=\"$COLOR_LEVEL_EMPTY\">▮▮▮▮▮▮▮▮▮▮</span>"
    else
        filled=$((percent / 10))
        [ "$filled" -eq 0 ] && filled=1
        empty=$((10 - filled))
        
        # Lista de cores para cada nível (0-9)
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
        [ "$filled" -eq 0 ] && filled=1
        empty=$((10 - filled))
        
        # Lista de cores para cada nível (0-9)
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

while true; do
    line=""

    if [ "$ENABLE_WORKSPACE" = true ]; then
        ws=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused==true).name')
        line="$line | WS: $ws"
    fi

    if [ "$ENABLE_AUDIO" = true ]; then
        vol=$(get_audio_volume)
        if [ "$ENABLE_VOLUME_BAR" = true ]; then
            vol_bar=$(draw_volume_bar "$vol")
            line="$line | Vol: $vol $vol_bar"
        else
            line="$line | Vol: $vol"
        fi
    fi

    if [ "$ENABLE_BATTERY" = true ]; then
        batt=$(get_battery_status)
        if [ "$ENABLE_BATTERY_BAR" = true ]; then
            batt_bar=$(draw_battery_bar "$batt")
            line="$line | Bat: $batt $batt_bar"
        else
            line="$line | Bat: $batt"
        fi
    fi

    if [ "$ENABLE_NETWORK" = true ]; then
        iface=""
        ip=""
        ssid=""
        for i in $INTERFACES; do
            ip_addr=$(ifconfig "$i" 2>/dev/null | awk '/inet /{print $2}')
            status=$(ifconfig "$i" 2>/dev/null | awk '/status:/{print $2}')
            if [ -n "$ip_addr" ] && \
               ( [ "$status" = "active" ] || [ "$status" = "UP" ] || [ "$status" = "RUNNING" ] || [ "$status" = "associated" ] ); then
                iface=$i
                ip=$ip_addr
                break
            fi
        done

        if [ "$iface" = "wlan0" ]; then
            ssid=$(ifconfig wlan0 2>/dev/null | awk '/ssid/ {print $2; exit}')
            net_info="Wi-Fi ($ssid) $ip"
        elif [ -n "$iface" ]; then
            net_info="Eth $ip"
        else
            net_info="Offline"
        fi
        line="$line | $net_info"
    fi

    time=$(date '+%Y-%m-%d %H:%M:%S')
    line="$line | $time"

    echo "${line# | }"
    sleep 1
done