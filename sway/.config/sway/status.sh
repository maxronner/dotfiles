# The Sway configuration file in ~/.config/sway/config calls this script.
# You should see changes to the status bar after saving this script.
# If not, do "killall swaybar" and $mod+Shift+c to reload the configuration.

# Produces "21 days", for example
uptime_formatted=$(uptime | cut -d ',' -f1  | cut -d ' ' -f4,5)

# The abbreviated weekday (e.g., "Sat"), followed by the ISO-formatted date
# like 2018-10-06 and the time (e.g., 14:01)
date_formatted=$(date "+%a %F %H:%M")

# Get the Linux version but remove the "-1-ARCH" part
linux_version=$(uname -r | cut -d '-' -f1)

# Returns the battery status: "Full", "Discharging", or "Charging".
battery_status=$(cat /sys/class/power_supply/BAT0/status)
battery_level=$(cat /sys/class/power_supply/BAT0/capacity)

ram_usage=$(free -h | awk 'NR==2' | awk '{print $3}')

if [ "$(ip -brief address | sed -n '2p' | awk '{print $2}')" == "UP" ]; then
    up=$"🌐"
else
    up=$"🚫"
fi

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
audio="$audio $volume%"

# Emojis and characters for the status bar
# 💎 💻 💡 🔌 ⚡ 📁 \|
echo $up \| $uptime_formatted \| 🐧 $linux_version \| $ram_usage \| $audio \| 🔋 $battery_status ${battery_level}% \| $date_formatted

