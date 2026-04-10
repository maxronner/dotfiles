# The Sway configuration file in ~/.config/sway/config calls this script.
# You should see changes to the status bar after saving this script.
# If not, do "killall swaybar" and $mod+Shift+c to reload the configuration.

if [[ -n "${HA_TOKEN_FILE:-}" && -f "${HA_TOKEN_FILE:-}" && -n "${HA_URL:-}" ]]; then
	walk=$(
		curl -s \
			--connect-timeout 2 \
			--max-time 5 \
			-H "Authorization: Bearer $(cat "$HA_TOKEN_FILE")" \
			-H "Content-Type: application/json" \
			"$HA_URL/api/states/sensor.walking_dog" |
			jq -r '.state // empty'
	) || true
fi
if [[ -n "${walk:-}" ]]; then
	output="🐶 $walk |"
fi

if [ "$(ip -brief address | awk 'NR==2 {print $2}')" == "UP" ]; then
	up=$"🌐 $(ip -brief address | awk 'NR==2 { print $3 }')"
else
	up=$"🚫"
fi
output="$output $up"

uptime_formatted=$(uptime | cut -d ',' -f1 | cut -d ' ' -f4,5)
output="$output | ⬆️ $uptime_formatted"

linux_version=$(uname -r | cut -d '-' -f1)
output="$output | 🐧 $linux_version"

ram_usage=$(free -h | awk 'NR==2' | awk '{print $3}')
output="$output | 📝 $ram_usage"

volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '/Volume:/ {print $5}' | tr -d '%')
muted=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
if [ "$volume" -eq 0 ] || [ "$muted" == "yes" ]; then
	audio="🔇"
elif [ "$volume" -le 33 ]; then
	audio="🔈"
elif [ "$volume" -le 66 ]; then
	audio="🔉"
else
	audio="🔊"
fi
output="$output | $audio $volume%"

if [[ -s /sys/class/power_supply/BAT0/status ]]; then
	battery_status=$(cat /sys/class/power_supply/BAT0/status)
	battery_level=$(cat /sys/class/power_supply/BAT0/capacity)
	if [ $battery_status == "Charging" ]; then
		icon="⚡"
	else
		if [ $battery_level -lt 25 ]; then
			icon="⚠️"
		fi
		icon="$icon🔋"
	fi
	output="$output | $icon $battery_status $battery_level%"
fi

date_formatted=$(date "+%a %F %H:%M")
output="$output | $date_formatted"

echo $output
