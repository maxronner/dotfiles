# The Sway configuration file in ~/.config/sway/config calls this script.
# You should see changes to the status bar after saving this script.
# If not, do "killall swaybar" and $mod+Shift+c to reload the configuration.

if [ "$(ip -brief address | sed -n '2p' | awk '{print $2}')" == "UP" ]; then
    up=$"🌐"
else
    up=$"🚫"
fi
output="$up"

# Produces "21 days", for example
uptime_formatted=$(uptime | cut -d ',' -f1  | cut -d ' ' -f4,5)
output="$output | $uptime_formatted"

# Get the Linux version but remove the "-1-ARCH" part
linux_version="🐧 $(uname -r | cut -d '-' -f1)"
output="$output | $linux_version"

ram_usage=$(free -h | awk 'NR==2' | awk '{print $3}')
output="$output | $ram_usage"

volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '/Volume:/ {print $5}' | tr -d '%')
muted=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
# Determine the speaker icon based on the volume level
if [ "$volume" -eq 0 ] || [ "$muted" == "yes" ] ; then
    audio="🔇"  # Muted
elif [ "$volume" -le 33 ]; then
    audio="🔈"  # Low volume
elif [ "$volume" -le 66 ]; then
    audio="🔉"  # Medium volume
else
    audio="🔊"  # High volume
fi
output="$output | $audio $volume%"

if [[ -s /sys/class/power_supply/BAT0/status ]] ; then
    # Returns the battery status: "Full", "Discharging", or "Charging".
    battery_status="🔋 $(cat /sys/class/power_supply/BAT0/status)"
    battery_level="$(cat /sys/class/power_supply/BAT0/capacity)%"
    output="$output | $battery_status $battery_level"
fi

# The abbreviated weekday (e.g., "Sat"), followed by the ISO-formatted date
# like 2018-10-06 and the time (e.g., 14:01)
date_formatted=$(date "+%a %F %H:%M")
output="$output | $date_formatted"

walk=$(curl -s \
  -H "Authorization: Bearer $HA_TOKEN" \
  -H "Content-Type: application/json" \
  https://home.ronner.dev/api/states/sensor.walking_dog \ |
jq '. | .state' | \
sed 's/"//g')
output="🐶 $walk | $output"

# Emojis and characters for the status bar
# 💎 💻 💡 🔌 ⚡ 📁 \|
echo $output
