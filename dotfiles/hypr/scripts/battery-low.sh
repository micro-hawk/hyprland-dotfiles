#!/bin/bash

get_perc() {
  capacity=$(cat "/sys/class/power_supply/${BAT}/capacity" 2>/dev/null)
  BATSTATUS=$(cat "/sys/class/power_supply/${BAT}/status" 2>/dev/null)
}

BAT=$(ls /sys/class/power_supply | grep BAT | head -n 1)

while true; do
  get_perc
  if [ -n "$BATSTATUS" ] && [ "$BATSTATUS" = "Discharging" ]; then
    if [ "$capacity" -le 14 ]; then
      notify-send "Battery Warning!" "Battery is at ${capacity}%"
      sleep 300
    else
      echo "Battery is at ${capacity}%"
      sleep 120
    fi
  fi
done



# #!/bin/bash
# while true; do
#   bat_lvl=$(cat /sys/class/power_supply/BAT1/capacity)
#   if [ "$bat_lvl" -le 15 ]; then
#     notify-send --urgency=CRITICAL "Battery Low" "Level: ${bat_lvl}%"
#     sleep 1200
#   else
#     sleep 120
#   fi
# done