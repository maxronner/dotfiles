#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Set default applications for common MIME types using xdg-mime.

Options:
  -i, --image-viewer <file.desktop>         Set default image viewer to the specified .desktop file.
  -w, --web-browser <file.desktop>          Set default web browser to the specified .desktop file.
  -v, --video-player <file.desktop>         Set default video player to the specified .desktop file.
  -a, --audio-player <file.desktop>         Set default audio player to the specified .desktop file.
  -t, --text-editor <file.desktop>          Set default text editor to the specified .desktop file.
  -p, --pdf-viewer <file.desktop>           Set default PDF viewer to the specified .desktop file.
  -b, --bittorrent-client <file.desktop>    Set default BitTorrent client to the specified .desktop file.
  -I, --interactive-image-viewer            Set default image viewer using interactive fzf prompt.
  -W, --interactive-web-browser             Set default web browser using interactive fzf prompt.
  -V, --interactive-video-player            Set default video player using interactive fzf prompt.
  -A, --interactive-audio-player            Set default audio player using interactive fzf prompt.
  -T, --interactive-text-editor             Set default text editor using interactive fzf prompt.
  -P, --interactive-pdf-viewer              Set default PDF viewer using interactive fzf prompt.
  -B, --interactive-bittorrent-client       Set default BitTorrent client using interactive fzf prompt.
  -h, --help                                Show this help message and exit

Interactive options launch an interactive fzf prompt to select a .desktop file.  Other options require a .desktop file to be passed as an argument.
EOF
  exit 0
}

if [ $# -eq 0 ]; then
  usage
fi

select_desktop_file() {
  local file
  file=$(find /usr/share/applications ~/.local/share/applications -name '*.desktop' 2>/dev/null \
    | sort -u | fzf --prompt="Select $1: ")
  if [[ -z "$file" ]]; then
    echo "No $1 was selected. Skipping." >&2
    return 1 # Indicate failure to select a file
  fi
  echo "$(basename "$file")"
  return 0 # Indicate success
}

set_mime_types() {
  local app="$1"
  local mime_types=("${@:2}") # All arguments after the first one
  local mime

  if [[ -z "$app" ]]; then
    return 1 # Indicate error: app name is empty
  fi

  for mime in "${mime_types[@]}"; do
    mime_map["$mime"]="$app"
  done
  return 0 # Indicate success
}

declare -A mime_map=()

OPTS=$(getopt \
  --options 'i:w:v:a:t:p:b:d:hIWVATPBD' \
  --longoptions 'image-viewer:,web-browser:,video-player:, \
    audio-player:,text-editor:,pdf-viewer:,bittorrent-client:,directory-explorer:,help,interactive-image-viewer, \
    interactive-web-browser,interactive-video-player,interactive-audio-player, \
    interactive-text-editor,interactive-pdf-viewer,interactive-bittorrent-client,interactive-directory-explorer' \
  --name "$(basename "$0")" \
  -- "$@") || exit 1

eval set -- "$OPTS"

# Helper function to handle option processing and error checking
process_option() {
  local option="$1"
  local app_type="$2"  # e.g., "image viewer", "web browser"
  local mime_types="$3" # Space-separated list of mime types
  local interactive="$4" # Flag to indicate interactive selection (true/false)

  if [[ "$interactive" == "true" ]]; then
    local app
    app=$(select_desktop_file "$app_type")
    if [[ -n "$app" ]]; then
      set_mime_types "$app" $mime_types
    fi
  else
    if [[ -n "$app_type" ]]; then
      set_mime_types "$app_type" $mime_types
    else
      echo "Error: Missing argument for $option" >&2
      usage
      return 1 # Indicate error
    fi
  fi
  return 0 # Indicate success
}

while true; do
  case "$1" in
    -i|--image-viewer)
      process_option "$1" "$2" "image/jpeg image/png image/gif image/webp image/svg+xml image/bmp" false && shift 2 || exit 1
      ;;
    -w|--web-browser)
      process_option "$1" "$2" "text/html x-scheme-handler/http x-scheme-handler/https" false && shift 2 || exit 1
      ;;
    -v|--video-player)
      process_option "$1" "$2" "video/mp4 video/x-matroska video/webm video/x-msvideo video/ogg" false && shift 2 || exit 1
      ;;
    -a|--audio-player)
      process_option "$1" "$2" "audio/mpeg audio/ogg audio/x-wav audio/flac" false && shift 2 || exit 1
      ;;
    -t|--text-editor)
      process_option "$1" "$2" "text/plain text/markdown" false && shift 2 || exit 1
      ;;
    -p|--pdf-viewer)
      process_option "$1" "$2" "application/pdf" false && shift 2 || exit 1
      ;;
    -b|--bittorrent-client)
      process_option "$1" "$2" "x-scheme-handler/magnet" false && shift 2 || exit 1
      ;;
    -d|--directory-explorer)
      process_option "$1" "$2" "inode/directory" false && shift 2 || exit 1
      ;;
    -I|--interactive-image-viewer)
      process_option "$1" "image viewer" "image/jpeg image/png image/gif image/webp image/svg+xml image/bmp" true && shift || exit 1
      ;;
    -W|--interactive-web-browser)
      process_option "$1" "web browser" "text/html x-scheme-handler/http x-scheme-handler/https" true && shift || exit 1
      ;;
    -V|--interactive-video-player)
      process_option "$1" "video player" "video/mp4 video/x-matroska video/webm video/x-msvideo video/ogg" true && shift || exit 1
      ;;
    -A|--interactive-audio-player)
      process_option "$1" "audio player" "audio/mpeg audio/ogg audio/x-wav audio/flac" true && shift || exit 1
      ;;
    -T|--interactive-text-editor)
      process_option "$1" "text editor" "text/plain text/markdown" true && shift || exit 1
      ;;
    -P|--interactive-pdf-viewer)
      process_option "$1" "PDF viewer" "application/pdf" true && shift || exit 1
      ;;
    -B|--interactive-bittorrent-client)
      process_option "$1" "BitTorrent client" "x-scheme-handler/magnet" true && shift || exit 1
      ;;
    -D|--interactive-directory-explorer)
      process_option "$1" "directory explorer" "inode/directory" true && shift || exit 1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Unexpected option: $1" >&2
      exit 1
      ;;
  esac
done

if [ ${#mime_map[@]} -eq 0 ]; then
  exit 0
fi

echo "Setting defaults..."
for mime in "${!mime_map[@]}"; do
  app="${mime_map[$mime]}"
  if ! find /usr/share/applications ~/.local/share/applications -name "$app" | grep -q .; then
    echo "Warning: .desktop file '$app' not found in standard locations. Skipping." >&2
    continue
  fi
  echo " → $mime → $app"
  if ! xdg-mime default "$app" "$mime"; then
    echo "Failed to set default for $mime to $app" >&2
  fi
done

echo "Done."

