#!/usr/bin/env bash

# Berus swaybar

# i3bar kompatibilis JSON kezdete
echo '{"version":1}'
echo '['
echo '[]'

# Folyamatos frissítés
while true; do
    # Memória
    mem_free=$(free -h | awk '/^Mem:/ {print $4}')
    mem="Memória: ${mem_free}"

    # Hálózat
    if ip route show default | grep -q wlan; then
        wifi=$(iwgetid -r)
        signal=$(awk 'NR==3 {print $3}' /proc/net/wireless | tr -d '.')
        net="WiFi: ${wifi} (${signal}%)"
    elif ip route show default | grep -q enp; then
        ipaddr=$(ip -4 addr show scope global | awk '/inet/ {print $2}' | cut -d'/' -f1 | head -n1)
        net="Hálózat: ${ipaddr:-–}"
    else
        net="Nincs hálózat"
    fi

    # Hangerő
    vol=$(pactl get-sink-volume @DEFAULT_SINK@ | head -n1 | awk '{print $5}' | tr -d '%')
    muted=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
    if [ "$muted" = "yes" ]; then
        audio="Hangerő: NÉMA"
    else
        audio="Hangerő: ${vol}%"
    fi

    # Dátum és idő (magyar formátum)
    time=$(date +"%Y. %B %d. %H:%M |")

    # Aktív ablak címének lekérése
    window_title=$(swaymsg -t get_tree | jq -r '.. | select(.type?) | select(.focused==true).name')

    # Ha túl hosszú a cím (pl. böngésző), érdemes levágni 30 karakternél
    window_title=$(echo "$window_title" | cut -c 1-30)

    # Ha nincs ablak fókuszban, ne legyen üres a helye
    #if [ "$window_title" == "null" ] || [ -z "$window_title" ]; then
     #   window_title="Asztal"
    #fi
    window="| Ablak: ${window_title}..."

    # Processzor
    cpu_load=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
    cpu="Processzor: ${cpu_load}%"
    
    # JSON kimenet (egy sorban)
    echo ",[{\"full_text\":\"$window | $cpu | ${mem} | ${net} | ${audio} | ${time}\"}]"

    sleep 2
done
