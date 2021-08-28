#!/bin/bash

POPUP_DURATION_SECONDS=2
POPUP_DURATION_MILLIS=$((POPUP_DURATION_SECONDS * 1000))
TIMESTAMP=''

update_variables() {
    VOLUME=$(amixer sget Master | awk '/Left:/ { print $5 }' | tr -d "[]%")     
    
    TIMESTAMP=$(($(date +%s%N | cut -b1-13) + POPUP_DURATION))

    MUTED=$(amixer get Master | awk '/Left:/ { print $6 }' | grep -c 'off')

    if [[ VOLUME -ge 100 ]]; then
        ICON_NAME="volume-high.svg"
    elif [[ VOLUME -ge 50 ]]; then
        ICON_NAME="volume-medium.svg"
    else
        ICON_NAME="volume-low.svg"
    fi

    if [[ MUTED -ne 0 ]]; then
        ICON_NAME="volume-muted.svg"
        VOLUME=0
    fi

    eww update volume=$VOLUME volume_popup-icon=$ICON_NAME volume_popup-timestamp=$TIMESTAMP
}

if [[ $1 == "up" ]]; then
    amixer -q sset Master 5%+
elif [[ $1 == "down" ]]; then
    amixer -q sset Master 5%-
elif [[ $1 == "mute" ]]; then
    amixer -q sset Master toggle
else
    exit 1
fi

$(update_variables)

eww open volume_popup

sleep ${POPUP_DURATION_SECONDS}.01s

NOW=$(date +%s%N | cut -b1-13)

CURRENT_TIMESTAMP=$(eww state --all | awk '/volume_popup-timestamp/ { print $2 }')

if [[ NOW -ge CURRENT_TIMESTAMP ]]; then
    eww close volume_popup
fi
