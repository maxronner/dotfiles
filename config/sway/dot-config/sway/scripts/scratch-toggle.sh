#!/bin/sh

# Dependency Check
command -v jq >/dev/null 2>&1 || { echo >&2 "Error: 'jq' is required."; exit 1; }
command -v swaymsg >/dev/null 2>&1 || { echo >&2 "Error: 'swaymsg' is required."; exit 1; }

# Default values
TARGET_APP_ID=""
TARGET_TITLE=""
TARGET_CLASS=""
CMD=""

# Help Function
show_help() {
    cat << EOF
Usage: $(basename "$0") [MATCH OPTIONS] -- [COMMAND]

Matches a Sway window using REGEX and toggles its state (Focus <-> Scratchpad).
If the window does not exist, it executes the provided COMMAND.

Match Options (Supports Regex):
  -a, --app-id <regex> Match by Wayland App ID
  -t, --title <regex>  Match by Window Title
  -c, --class <regex>  Match by XWayland Window Class
  -h, --help           Show this help message

Examples:
  # Regex match for Chrome App (starts with...)
  $(basename "$0") --app-id '^chrome-home\.ronner\.dev' -- chromium --app="https://home.ronner.dev/"

  # Substring match for title
  $(basename "$0") --title 'btop' -- foot -e btop
EOF
}

# Argument Parsing
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help) show_help; exit 0 ;;
        -a|--app-id) TARGET_APP_ID="$2"; shift 2 ;;
        -t|--title) TARGET_TITLE="$2"; shift 2 ;;
        -c|--class) TARGET_CLASS="$2"; shift 2 ;;
        --) shift; CMD="$*"; break ;;
        -*) echo "Error: Unknown option $1" >&2; show_help; exit 1 ;;
        *)
           # Handle case where -- was omitted
           if [ -z "$CMD" ]; then CMD="$*"; break; fi
           ;;
    esac
done

# Validation
if [ -z "$TARGET_APP_ID" ] && [ -z "$TARGET_TITLE" ] && [ -z "$TARGET_CLASS" ]; then
    echo "Error: You must provide at least one matching criteria." >&2
    exit 1
fi

if [ -z "$CMD" ]; then
    echo "Error: No command provided to execute." >&2
    exit 1
fi

# Query Sway tree
# logic: recurse tree -> select windows -> filter by regex provided in args
window_info=$(swaymsg -t get_tree | jq \
    --arg app_id "$TARGET_APP_ID" \
    --arg title "$TARGET_TITLE" \
    --arg class "$TARGET_CLASS" \
    '
    recurse(.nodes[]?, .floating_nodes[]?) |
    select(.type == "con" or .type == "floating_con") |
    select(
        ($app_id == "" or (.app_id != null and (.app_id | test($app_id)))) and
        ($title == "" or (.name != null and (.name | test($title)))) and
        ($class == "" or (.window_properties.class != null and (.window_properties.class | test($class))))
    ) |
    {id, focused, visible, scratchpad_state}
    ' | jq -s '.[0] // empty')

# 1. No such window found → launch new
if [ -z "$window_info" ]; then
    nohup $CMD >/dev/null 2>&1 &
    exit 0
fi

# Extract values
id=$(echo "$window_info" | jq -r '.id // empty')
focused=$(echo "$window_info" | jq -r '.focused // false')
scratchpad_state=$(echo "$window_info" | jq -r '.scratchpad_state // "none"')

if [ -z "$id" ]; then echo "Error: Failed to get ID."; exit 1; fi

# 2. Toggle Logic
if [ "$focused" = "true" ]; then
    swaymsg "[con_id=$id] move scratchpad" > /dev/null
elif [ "$scratchpad_state" != "none" ]; then
    swaymsg "[con_id=$id] scratchpad show" > /dev/null
else
    swaymsg "[con_id=$id] move to workspace current; [con_id=$id] focus" > /dev/null
fi
