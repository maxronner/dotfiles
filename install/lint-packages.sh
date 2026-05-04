#!/usr/bin/env bash
# Validate package manifest placement and entries.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"
source "${SCRIPT_DIR}/packages.sh"

require_child_manifests() {
    local root="$1"
    local failures=0
    local dir

    [[ -d "$root" ]] || return 0

    for dir in "$root"/*/; do
        [[ -d "$dir" ]] || continue
        if [[ ! -f "${dir}/pkg.txt" ]]; then
            error "Missing pkg.txt: ${dir}"
            failures=$((failures + 1))
        fi
    done

    (( failures == 0 ))
}

if (( $# > 0 )); then
    roots=("$@")
else
    roots=(
        "${DOTS_DIR}/apps"
        "${DOTS_DIR}/system"
        "${DOTS_DIR}/devices"
        "${DOTS_DIR}/optional"
    )
fi

missing=0
for root in "${roots[@]}"; do
    require_child_manifests "$root" || missing=1
done

validate_package_manifests "${roots[@]}" || missing=1

if (( missing != 0 )); then
    exit 1
fi

success "Package manifests are valid."
