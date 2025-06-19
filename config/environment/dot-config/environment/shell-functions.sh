fat() {
  local result
  # Use --color=never to ensure wc -l counts actual lines, not ANSI escape codes
  result="$(fd --absolute-path --color=never --type file "$@" .)"
  local line_count
  line_count=$(echo "$result" | wc -l)

  if [ -z "$result" ]; then
    echo "No files found."
  elif [ "$line_count" -gt 1 ]; then
    local selected_file
    selected_file=$(echo "$result" | fzf)
    if [ -n "$selected_file" ]; then
      cat "$selected_file"
    else
      echo "Selection cancelled."
    fi
  else # line_count is 1
    cat "$result"
  fi
}
