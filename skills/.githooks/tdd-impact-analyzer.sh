#!/usr/bin/env bash
# =============================================================================
# tdd-impact-analyzer.sh
# Purpose: Analyze changed files and find potentially impacted test classes
# Input:   Changed file list (newline-separated), passed via stdin or $1
# Output:  Comma-separated list of impacted Test class names (to stdout)
#          Diagnostic logs go to stderr
# Compatible with bash 3.2+ (macOS default)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

log() { echo "[tdd-analyzer] $*" >&2; }

# ── Dedup helper (bash 3 compatible) ──────────────────────────────────────────
# Uses pipe-delimited string as a poor-man's set
# is_in_list <item> <pipe_delimited_list>
is_in_list() {
    local item="$1" list="$2"
    [[ "|${list}|" == *"|${item}|"* ]]
}

# append_to_list <item> <pipe_delimited_list_varname>
append_to_list() {
    local item="$1" varname="$2"
    local current="${!varname}"
    if [[ -z "$current" ]]; then
        eval "$varname=\"$item\""
    else
        eval "$varname=\"${current}|${item}\""
    fi
}

# ── Strategy 1: Same-module same-package direct match ────────────────────────
# FooService.java → FooServiceTest.java in mirror test path (same module)
find_direct_test() {
    local file="$1"
    [[ "$file" =~ \.java$ ]] || return 0
    [[ "$file" =~ /src/main/java/ ]] || return 0

    local base dir test_dir
    base=$(basename "$file" .java)
    dir=$(dirname "$file")
    test_dir="${dir/\/src\/main\/java\//\/src\/test\/java\/}"

    if [[ -d "$PROJECT_ROOT/$test_dir" ]]; then
        find "$PROJECT_ROOT/$test_dir" -maxdepth 1 \
            -name "${base}Test.java" \
            2>/dev/null || true
    fi
}

# ── Strategy 2: Same-module same-package all tests ───────────────────────────
find_package_tests() {
    local file="$1"
    [[ "$file" =~ \.java$ ]] || return 0
    [[ "$file" =~ /src/main/java/ ]] || return 0

    local dir test_dir
    dir=$(dirname "$file")
    test_dir="${dir/\/src\/main\/java\//\/src\/test\/java\/}"

    if [[ -d "$PROJECT_ROOT/$test_dir" ]]; then
        find "$PROJECT_ROOT/$test_dir" -maxdepth 1 \
            -name "*Test.java" \
            2>/dev/null || true
    fi
}

# ── Strategy 3: Cross-module class-name search ───────────────────────────────
# Search ALL *Test.java files across the entire project that reference this class.
# Catches: cross-module tests, tests in non-mirrored packages (e.g. unittest/)
find_cross_module_tests() {
    local file="$1"
    [[ "$file" =~ \.java$ ]] || return 0
    [[ "$file" =~ /src/main/java/ ]] || return 0

    local base
    base=$(basename "$file" .java)

    # Only search in src/test directories, exclude build/cache directories
    # Use -maxdepth to limit recursion depth for performance
    find "$PROJECT_ROOT" -type d \( -name "target" -o -name ".git" -o -name ".idea" -o -name ".venv" -o -name "node_modules" -o -name ".qoder" -o -name ".sisyphus" \) -prune -o \
        -path "*/src/test/java/*Test.java" -print0 2>/dev/null | \
        xargs -0 grep -l "$base" 2>/dev/null || true
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
    local changed_files
    if [[ -n "${1:-}" ]]; then
        changed_files="$1"
    else
        changed_files=$(cat)
    fi

    if [[ -z "$changed_files" ]]; then
        log "No changed files provided"
        echo ""
        exit 0
    fi

    log "Analyzing changed files..."

    local impacted_list=""

    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        [[ "$file" =~ /src/test/ ]] && continue

        log "  -> $file"

        # Strategy 1: Direct test match (same module, same package)
        while IFS= read -r test_file; do
            [[ -z "$test_file" ]] && continue
            local cn
            cn=$(basename "$test_file" .java)
            if ! is_in_list "$cn" "$impacted_list"; then
                append_to_list "$cn" impacted_list
                log "    [direct] $cn"
            fi
        done < <(find_direct_test "$file")

        # Strategy 2: Package-level tests (same module, same package)
        while IFS= read -r test_file; do
            [[ -z "$test_file" ]] && continue
            local cn
            cn=$(basename "$test_file" .java)
            if ! is_in_list "$cn" "$impacted_list"; then
                append_to_list "$cn" impacted_list
                log "    [package] $cn"
            fi
        done < <(find_package_tests "$file")

        # Strategy 3: Cross-module grep (catches idle-erp-web tests for idle-erp-service classes)
        while IFS= read -r test_file; do
            [[ -z "$test_file" ]] && continue
            local cn
            cn=$(basename "$test_file" .java)
            if ! is_in_list "$cn" "$impacted_list"; then
                append_to_list "$cn" impacted_list
                log "    [cross-module] $cn"
            fi
        done < <(find_cross_module_tests "$file")

    done <<< "$changed_files"

    if [[ -z "$impacted_list" ]]; then
        log "No impacted tests found"
        echo ""
    else
        local result="${impacted_list//|/,}"
        local count
        count=$(echo "$result" | tr ',' '\n' | wc -l | tr -d ' ')
        log "Found $count impacted test(s)"
        echo "$result"
    fi
}

main "${1:-}"
