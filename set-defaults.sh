#!/usr/bin/env bash

set -euo pipefail

usage() {
cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Set default applications for common MIME types using xdg-mime.

Options:
  -i, --image-viewer        Set default image viewer
  -w, --web-browser         Set default web browser
  -v, --video-player        Set default video player
  -a, --audio-player        Set default audio player
  -t, --text-editor         Set default text editor
  -p, --pdf-viewer          Set default PDF viewer
  -h, --help                Show this help message and exit

All options launch an interactive fzf prompt to select a .desktop file.
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
  fi
  echo "$(basename "$file")"
}

declare -A mime_map=()

OPTS=$(getopt \
  --options iwvatph \
  --longoptions image-viewer,web-browser,video-player,audio-player,text-editor,pdf-viewer,help \
  --name "$(basename "$0")" \
  -- "$@"
) || exit 1

eval set -- "$OPTS"

while true; do
  case "$1" in
    -i|--image-viewer)
      app=$(select_desktop_file "image viewer")
      if [[ -n "$app" ]]; then
        echo "Setting image viewer to $app"
        for m in image/jpeg image/png image/gif image/webp image/svg+xml image/bmp; do
          mime_map["$m"]="$app"
        done
      fi
      shift
      ;;
    -w|--web-browser)
      app=$(select_desktop_file "web browser")
      if [[ -n "$app" ]]; then
        for m in text/html x-scheme-handler/http x-scheme-handler/https; do
          mime_map["$m"]="$app"
        done
      fi
      shift
      ;;
    -v|--video-player)
      app=$(select_desktop_file "video player")
      if [[ -n "$app" ]]; then
        for m in video/mp4 video/x-matroska video/webm video/x-msvideo video/ogg; do
          mime_map["$m"]="$app"
        done
      fi
      shift
      ;;
    -a|--audio-player)
      app=$(select_desktop_file "audio player")
      if [[ -n "$app" ]]; then
        for m in audio/mpeg audio/ogg audio/x-wav audio/flac; do
          mime_map["$m"]="$app"
        done
      fi
      shift
      ;;
    -t|--text-editor)
      app=$(select_desktop_file "text editor")
      if [[ -n "$app" ]]; then
        for m in text/plain text/markdown; do
          mime_map["$m"]="$app"
        done
      fi
      shift
      ;;
    -p|--pdf-viewer)
      app=$(select_desktop_file "PDF viewer")
      if [[ -n "$app" ]]; then
        mime_map["application/pdf"]="$app"
      fi
      shift
      ;;
    -h|--help)
      usage
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
    if ! find /usr/share/applications ~/.local/share/applications -name "$app" | grep -q .; then
      echo "Warning: .desktop file '$app' not found in standard locations. Skipping." >&2
      continue
    fi

    app="${mime_map[$mime]}"
    echo " → $mime → $app"
    if ! xdg-mime default "$app" "$mime"; then
      echo "Failed to set default for $mime to $app" >&2
fi

done

echo "Done."

