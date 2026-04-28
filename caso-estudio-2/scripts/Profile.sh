#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUT_DIR="stats/${HOSTNAME}/profiling_${TIMESTAMP}"
mkdir -p "$OUT_DIR"

# N=1000 for gprof/memory (~1.8s); N=2000 for sample (~16s, needs longer run)
N_FAST=1000
N_SAMPLE=2000

echo "=== Profiling run: host=${HOSTNAME} ==="
echo "Output: $OUT_DIR"

# ── Build ─────────────────────────────────────────────────────────────────────
echo ""
echo "[1/3] Building binaries..."
make output/secuential output/profiling 2>&1 | grep -v "^make\[" | tail -5

# ── CPU profiling ─────────────────────────────────────────────────────────────
echo ""
echo "[2/3] CPU profiling..."

if [[ "$(uname)" == "Darwin" ]]; then
    # macOS: statistical profiler via `sample` (samples call stack at ~1ms intervals)
    echo "  Tool: sample (statistical/sampling profiler), N=${N_SAMPLE}"
    ./output/profiling "$N_SAMPLE" &
    APP_PID=$!
    # Sample for up to 60s or until the process exits
    sample "$APP_PID" 60 -file "$OUT_DIR/cpu_sample.txt" > /dev/null 2>&1 || true
    wait "$APP_PID" 2>/dev/null || true
    echo "  -> cpu_sample.txt"
    echo ""
    echo "--- CPU sample (top 30 lines) ---"
    head -30 "$OUT_DIR/cpu_sample.txt"
    echo "---------------------------------"
else
    # Linux: event-based profiler via gprof (instruments every function call)
    echo "  Tool: gprof (event-based/tracing profiler), N=${N_FAST}"
    rm -f gmon.out
    ./output/profiling "$N_FAST"
    gprof -b output/profiling gmon.out > "$OUT_DIR/gprof_flat.txt"
    gprof -b -q output/profiling gmon.out > "$OUT_DIR/gprof_callgraph.txt"
    cp gmon.out "$OUT_DIR/gmon.out"
    echo "  -> gprof_flat.txt"
    echo "  -> gprof_callgraph.txt"
    echo ""
    echo "--- gprof flat profile (top 20 lines) ---"
    head -25 "$OUT_DIR/gprof_flat.txt" | grep -v '^$' | head -20
    echo "------------------------------------------"
fi

# ── Memory profiling ──────────────────────────────────────────────────────────
echo ""
echo "[3/3] Memory profiling (N=${N_FAST})..."

if [[ "$(uname)" == "Darwin" ]]; then
    # macOS: /usr/bin/time -l reports peak RSS, page faults, page reclaims
    /usr/bin/time -l ./output/secuential "$N_FAST" 2> "$OUT_DIR/memory_peak.txt" || true
    echo "  -> memory_peak.txt (peak RSS via /usr/bin/time -l)"
    echo ""
    echo "--- Memory summary ---"
    grep -E "maximum resident|page reclaims|page faults" "$OUT_DIR/memory_peak.txt" || \
        head -15 "$OUT_DIR/memory_peak.txt"
    echo "----------------------"
else
    # Linux: valgrind --tool=massif for heap allocation over time
    if command -v valgrind &>/dev/null; then
        valgrind --tool=massif \
            --massif-out-file="$OUT_DIR/massif.out" \
            ./output/secuential "$N_FAST" 2> "$OUT_DIR/valgrind_stderr.txt" || true
        if command -v ms_print &>/dev/null; then
            ms_print "$OUT_DIR/massif.out" > "$OUT_DIR/massif_report.txt"
            echo "  -> massif.out + massif_report.txt"
            echo ""
            echo "--- Massif heap chart (top 35 lines) ---"
            head -35 "$OUT_DIR/massif_report.txt"
            echo "----------------------------------------"
        fi
        # Also capture peak RSS
        /usr/bin/time -v ./output/secuential "$N_FAST" 2> "$OUT_DIR/memory_peak.txt" || true
        grep "Maximum resident" "$OUT_DIR/memory_peak.txt" || true
    else
        echo "  valgrind not found — using /usr/bin/time -v"
        /usr/bin/time -v ./output/secuential "$N_FAST" 2> "$OUT_DIR/memory_peak.txt" || true
        grep "Maximum resident" "$OUT_DIR/memory_peak.txt" || true
    fi
    echo "  -> memory_peak.txt"
fi

echo ""
echo "=== Done. Results in: $OUT_DIR ==="
ls -lh "$OUT_DIR"
