#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
SCRIPT="$SCRIPT_DIR/../../../dot-local/bin/nvim-attach"
TEST_LIB="$SCRIPT_DIR/lib/tmux-test.sh"

# shellcheck source=lib/tmux-test.sh
source "$TEST_LIB"

make_socket() {
	local socket_path=$1

	python3 - "$socket_path" <<'PY' &
import os
import socket
import sys
import time

path = sys.argv[1]
os.makedirs(os.path.dirname(path), exist_ok=True)
try:
    os.unlink(path)
except FileNotFoundError:
    pass

sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.bind(path)
sock.listen(1)
time.sleep(30)
PY

	printf '%s\n' "$!"
}

make_fake_bin() {
	local fakebin
	fakebin=$(mktemp -d)

	cat >"$fakebin/tmux" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf '%q ' "$@" >>"$FAKE_TMUX_LOG"
printf '\n' >>"$FAKE_TMUX_LOG"

case "${1-}" in
display-message)
  if [[ ${2-} == "-p" && ${3-} == "#S" ]]; then
    printf 'sess\n'
  elif [[ ${2-} == "-p" && ${3-} == '#{session_id}' ]]; then
    printf '$7\n'
  else
    printf 'unsupported display-message invocation\n' >&2
    exit 98
  fi
  ;;
list-panes)
  if [[ ${2-} == "-s" && ${3-} == "-t" && ${4-} == "sess" ]]; then
    printf '1 1 zsh\n'
    printf '2 1 nvim\n'
  else
    printf 'unsupported list-panes invocation\n' >&2
    exit 98
  fi
  ;;
select-window | select-pane)
  ;;
*)
  printf 'unsupported tmux invocation: %s\n' "$*" >&2
  exit 99
  ;;
esac
EOF

	cat >"$fakebin/nvim" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf '%q ' "$@" >>"$FAKE_NVIM_LOG"
printf '\n' >>"$FAKE_NVIM_LOG"
exit 0
EOF

	chmod +x "$fakebin/tmux" "$fakebin/nvim"
	printf '%s\n' "$fakebin"
}

test_attaches_to_nvim_pane_in_another_window() {
	local runtime_dir fakebin tmux_log nvim_log socket_pid log
	runtime_dir=$(mktemp -d)
	fakebin=$(make_fake_bin)
	tmux_log=$(mktemp)
	nvim_log=$(mktemp)

	socket_pid=$(make_socket "$runtime_dir/nvim-sockets/nvim-7.sock")
	trap 'kill "$socket_pid" 2>/dev/null || true' RETURN

	PATH="$fakebin:$PATH" \
		XDG_RUNTIME_DIR="$runtime_dir" \
		FAKE_TMUX_LOG="$tmux_log" \
		FAKE_NVIM_LOG="$nvim_log" \
		"$SCRIPT"

	log=$(<"$tmux_log")

	assert_contains "$log" "list-panes -s -t sess"
	assert_contains "$log" "select-window -t sess:2"
	assert_contains "$log" "select-pane -t sess:2.1"
	assert_not_contains "$log" "new-window"
}

main() {
	test_attaches_to_nvim_pane_in_another_window
	printf 'nvim-attach tests passed\n'
}

main "$@"
