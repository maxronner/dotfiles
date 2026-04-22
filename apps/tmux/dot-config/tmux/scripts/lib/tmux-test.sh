#!/usr/bin/env bash

fail() {
	printf 'FAIL: %s\n' "$*" >&2
	exit 1
}

assert_contains() {
	local haystack=$1
	local needle=$2
	[[ $haystack == *"$needle"* ]] || fail "expected to find '$needle' in: $haystack"
}

assert_not_contains() {
	local haystack=$1
	local needle=$2
	[[ $haystack != *"$needle"* ]] || fail "did not expect to find '$needle' in: $haystack"
}

make_fake_tmux_bin() {
	local fakebin
	fakebin=$(mktemp -d)

	cat >"$fakebin/tmux" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

log_call() {
  local line
  printf -v line '%q ' "$@"
  printf '%s\n' "${line% }" >>"$FAKE_TMUX_LOG"
}

log_call "$@"

case "${1-}" in
display | display-message)
  if [[ ${2-} == "-p" && ${3-} == "#S" ]]; then
    printf 'sess\n'
  elif [[ ${2-} == "-p" && ${3-} == "#I" ]]; then
    printf '1\n'
  elif [[ ${2-} == "-p" && ${3-} == "-F" && ${4-} == '#{pane_current_path}' ]]; then
    printf '/tmp\n'
  elif [[ ${2-} == "-p" && ${3-} == "-t" && ${4-} == "sess:2" && ${5-} == '#{pane_id}' ]]; then
    printf '%%42\n'
  elif [[ ${2-} == "-p" && ${3-} == "-t" && ${4-} == "%42" && ${5-} == '#{window_index}' ]]; then
    printf '2\n'
  elif [[ ${2-} == "-p" && ${3-} == "-t" && ${4-} == "sess:2.1" && ${5-} == '#{window_index}' ]]; then
    printf '2\n'
  elif [[ ${2-} == "-p" && ${3-} == "-t" && ${4-} == "sess:1.1" && ${5-} == '#{window_index}' ]]; then
    printf '1\n'
  else
    printf 'unsupported display invocation\n' >&2
    exit 98
  fi
  ;;
list-panes)
  if [[ ${2-} == "-a" ]]; then
    case "${FAKE_TMUX_SCENARIO:-create}" in
    move)
      printf 'sess:2.1 __scratch__ 1\n'
      ;;
    *) ;;
    esac
  else
    printf '0\n'
  fi
  ;;
list-windows)
  case "${FAKE_TMUX_SCENARIO:-create}" in
  unmarked-move)
    printf 'sess:2 opencode 0\n'
    ;;
  *)
    printf '0\n2\n'
    ;;
  esac
  ;;
split-window)
  printf '%%42\n'
  ;;
select-window)
  case "${FAKE_TMUX_SCENARIO:-create}" in
  existing)
    ;;
  *)
    exit 1
    ;;
  esac
  ;;
set-option | select-pane | move-pane | break-pane | new-window)
  ;;
*)
  printf 'unsupported tmux invocation: %s\n' "$*" >&2
  exit 99
  ;;
esac
EOF

	chmod +x "$fakebin/tmux"
	printf '%s\n' "$fakebin"
}

run_with_fake_tmux() {
	local scenario=$1
	local script=$2
	shift 2

	local fakebin logfile
	fakebin=$(make_fake_tmux_bin)
	logfile=$(mktemp)

	PATH="$fakebin:$PATH" FAKE_TMUX_LOG="$logfile" FAKE_TMUX_SCENARIO="$scenario" "$script" "$@"

	cat "$logfile"
}

run_shell_with_fake_tmux() {
	local scenario=$1
	local command=$2

	local fakebin logfile
	fakebin=$(make_fake_tmux_bin)
	logfile=$(mktemp)

	PATH="$fakebin:$PATH" FAKE_TMUX_LOG="$logfile" FAKE_TMUX_SCENARIO="$scenario" bash -c "$command"

	cat "$logfile"
}
