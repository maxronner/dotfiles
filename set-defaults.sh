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

while true; do
  case "$1" in
    -i|--image-viewer)
      if [[ -n "$2" ]]; then
        set_mime_types "$2" image/jpeg image/png image/gif image/webp image/svg+xml image/bmp
        shift 2
      else
        echo "Error: Missing argument for $1" >&2
        usage
      fi
      ;;
    -w|--web-browser)
      if [[ -n "$2" ]]; then
        set_mime_types "$2" text/html x-scheme-handler/http x-scheme-handler/https
        shift 2
      else
        echo "Error: Missing argument for $1" >&2
        usage
      fi
      ;;
    -v|--video-player)
      if [[ -n "$2" ]]; then
        set_mime_types "$2" video/mp4 video/x-matroska video/webm video/x-msvideo video/ogg
        shift 2
      else
        echo "Error: Missing argument for $1" >&2
        usage
      fi
      ;;
    -a|--audio-player)
      if [[ -n "$2" ]]; then
        set_mime_types "$2" audio/mpeg audio/ogg audio/x-wav audio/flac
        shift 2
      else
        echo "Error: Missing argument for $1" >&2
        usage
      fi
      ;;
    -t|--text-editor)
      if [[ -n "$2" ]]; then
        set_mime_types "$2" text/plain text/markdown
        shift 2
      else
        echo "Error: Missing argument for $1" >&2
        usage
      fi
      ;;
    -p|--pdf-viewer)
      if [[ -n "$2" ]]; then
        set_mime_types "$2" application/pdf
        shift 2
      else
        echo "Error: Missing argument for $1" >&2
        usage
      fi
      ;;
    -b|--bittorrent-client)
      if [[ -n "$2" ]]; then
        set_mime_types "$2" x-scheme-handler/magnet
        shift 2
      else
        echo "Error: Missing argument for $1" >&2
        usage
      fi
      ;;
    -d|--directory-explorer)
      if [[ -n "$2" ]]; then
        set_mime_types "$2" inode/directory
        shift 2
      else
        echo "Error: Missing argument for $1" >&2
        usage
      fi
      ;;
    -I|--interactive-image-viewer)
      if app=$(select_desktop_file "image viewer"); then
        set_mime_types "$app" image/jpeg image/png image/gif image/webp image/svg+xml image/bmp
      fi
      shift
      ;;
    -W|--interactive-web-browser)
      if app=$(select_desktop_file "web browser"); then
        set_mime_types "$app" text/html x-scheme-handler/http x-scheme-handler/https
      fi
      shift
      ;;
    -V|--interactive-video-player)
      if app=$(select_desktop_file "video player"); then
        set_mime_types "$app" video/mp4 video/x-matroska video/webm video/x-msvideo video/ogg
      fi
      shift
      ;;
    -A|--interactive-audio-player)
      if app=$(select_desktop_file "audio player"); then
        set_mime_types "$app" audio/mpeg audio/ogg audio/x-wav audio/flac
      fi
      shift
      ;;
    -T|--interactive-text-editor)
      if app=$(select_desktop_file "text editor"); then
        set_mime_types "$app" text/plain text/markdown
      fi
      shift
      ;;
    -P|--interactive-pdf-viewer)
      if app=$(select_desktop_file "PDF viewer"); then
        set_mime_types "$app" application/pdf
      fi
      shift
      ;;
    -B|--interactive-bittorrent-client)
      if app=$(select_desktop_file "BitTorrent client"); then
        set_mime_types "$app" x-scheme-handler/magnet
      fi
      shift
      ;;
    -D|--interactive-directory-explorer)
      if app=$(select_desktop_file "directory explorer"); then
        set_mime_types "$app" inode/directory
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

