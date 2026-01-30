_getclip() {
  CLIP=()
  if command -v wl-copy >/dev/null 2>&1; then
    CLIP=(wl-copy)
  elif command -v xclip >/dev/null 2>&1; then
    CLIP=(xclip -selection clipboard)
  elif command -v pbcopy >/dev/null 2>&1; then
    CLIP=(pbcopy)
  else
    echo "No clipboard tool found (wl-copy, xclip, pbcopy)" >&2
    return 1
  fi
  printf '%s ' "${CLIP[@]}"
}

niceclip() {
  if ! cmd_script="$(_getclip)"; then
    return 1
  fi
  nicecat "$@" | eval "$cmd_script"
}

treeclip() {
  if ! cmd_script="$(_getclip)"; then
    return 1
  fi
  treecat "${1:-.}" | eval "$cmd_script"
}
