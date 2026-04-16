#!/usr/bin/env bash
# =============================================================================
# tdd-test-runner.sh
# Purpose: Run specified test classes, auto-locating which module each belongs to
# Input:   $1 = comma-separated list of test class names (or empty = run all)
#          $2 = optional module override (e.g., idle-erp-web)
# Output:  Pass/Fail status, exit 0 on success, exit 1 on failure
# Compatible with bash 3.2+ (macOS default)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TESTS="${1:-}"
TARGET_MODULE="${2:-}"

log()  { echo "[tdd-runner] $*"; }
pass() { echo "OK  [tdd-runner] $*"; }
fail() { echo "ERR [tdd-runner] $*" >&2; }

ALL_MODULES=(
    "idle-erp-domain"
    "idle-erp-infra"
    "idle-erp-service"
    "idle-erp-web"
)

# Find which module contains a given test class file.
# Returns module name, or empty string if not found.
find_module_for_test() {
    local test_class="$1"
    local mod
    for mod in "${ALL_MODULES[@]}"; do
        local test_dir="$PROJECT_ROOT/$mod/src/test"
        if [[ -d "$test_dir" ]]; then
            if find "$test_dir" -name "${test_class}.java" 2>/dev/null | grep -q .; then
                echo "$mod"
                return 0
            fi
        fi
    done
    echo ""
}

# Run Maven test for a single module with optional test filter.
run_tests_in_module() {
    local module="$1"
    local test_filter="${2:-}"

    if [[ ! -d "$PROJECT_ROOT/$module" ]]; then
        log "Module $module not found, skipping"
        return 0
    fi

    # -nsu: skip SNAPSHOT update checks (huge speedup, avoids network round-trips)
    local mvn_args=(-pl "$module" -DfailIfNoTests=false -nsu -q)
    if [[ -n "$test_filter" ]]; then
        mvn_args+=(-Dtest="$test_filter")
    fi

    log "Running ${test_filter:-all tests} in $module ..."
    cd "$PROJECT_ROOT"

    if mvn test "${mvn_args[@]}" 2>&1; then
        pass "$module / ${test_filter:-*}: PASSED"
        return 0
    else
        fail "$module / ${test_filter:-*}: FAILED"
        return 1
    fi
}

main() {
    # Explicit module override
    if [[ -n "$TARGET_MODULE" ]]; then
        run_tests_in_module "$TARGET_MODULE" "$TESTS"
        exit $?
    fi

    # No tests specified: full suite
    if [[ -z "$TESTS" ]]; then
        log "No test filter — running full suite on all modules"
        local failed=0
        local mod
        for mod in "${ALL_MODULES[@]}"; do
            run_tests_in_module "$mod" || failed=1
        done
        [[ $failed -ne 0 ]] && { fail "One or more modules FAILED"; exit 1; }
        pass "Full suite passed"
        exit 0
    fi

    # Specific tests: locate each class, run only in its owning module
    log "Tests to run: $TESTS"
    local failed=0
    local ran=0

    # Convert comma-separated list to newline-separated for safe iteration
    local test_class
    while IFS= read -r test_class; do
        # trim whitespace
        test_class="${test_class#"${test_class%%[![:space:]]*}"}"
        test_class="${test_class%"${test_class##*[![:space:]]}"}"
        [[ -z "$test_class" ]] && continue

        local module
        module=$(find_module_for_test "$test_class")

        if [[ -z "$module" ]]; then
            log "WARNING: $test_class not found in any module — skipping"
            continue
        fi

        log "Located $test_class → $module"
        ran=$((ran + 1))
        run_tests_in_module "$module" "$test_class" || failed=1

    done < <(echo "$TESTS" | tr ',' '\n')

    if [[ $ran -eq 0 ]]; then
        log "WARNING: No test classes located for: $TESTS"
        exit 0
    fi

    [[ $failed -ne 0 ]] && { fail "Tests FAILED: $TESTS"; exit 1; }
    pass "All tests passed: $TESTS"
    exit 0
}

main
