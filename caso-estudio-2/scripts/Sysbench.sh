#!/bin/bash

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEVICE_NAME=$(hostname)
STATS_BASE="$ROOT_DIR/stats/$DEVICE_NAME"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUT_DIR="$STATS_BASE/sysbench_$TIMESTAMP"
mkdir -p "$OUT_DIR"

# ─── Check sysbench ───────────────────────────────────────────────────────────
if ! command -v sysbench &>/dev/null; then
  echo "[ERROR] sysbench no está instalado."
  if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "  Instalar con: brew install sysbench"
  else
    echo "  Instalar con: sudo apt install sysbench"
  fi
  exit 1
fi

sysbench --version | tee "$OUT_DIR/version.txt"

# Detect logical CPU count (macOS vs Linux)
if [[ "$(uname -s)" == "Darwin" ]]; then
  NUM_THREADS=$(sysctl -n hw.logicalcpu)
else
  NUM_THREADS=$(nproc)
fi

echo "Máquina: $DEVICE_NAME | Threads disponibles: $NUM_THREADS"
echo ""

# ─── CPU benchmark ────────────────────────────────────────────────────────────
echo "[1/3] CPU benchmark (1 thread) ..."
sysbench cpu --cpu-max-prime=20000 --threads=1 run > "$OUT_DIR/cpu_1thread.txt"

echo "[2/3] CPU benchmark ($NUM_THREADS threads) ..."
sysbench cpu --cpu-max-prime=20000 --threads="$NUM_THREADS" run > "$OUT_DIR/cpu_allthreads.txt"

# ─── Memory benchmark ─────────────────────────────────────────────────────────
echo "[3/3] Memory benchmark (read + write) ..."
sysbench memory --memory-block-size=1M --memory-total-size=10G --memory-oper=write \
  --threads="$NUM_THREADS" run > "$OUT_DIR/memory_write.txt"
sysbench memory --memory-block-size=1M --memory-total-size=10G --memory-oper=read \
  --threads="$NUM_THREADS" run > "$OUT_DIR/memory_read.txt"

# ─── Parse to summary CSV ─────────────────────────────────────────────────────
SUMMARY="$OUT_DIR/summary.csv"
echo "test,metric,value,unit" > "$SUMMARY"

extract_cpu() {
  local file="$1" label="$2"
  local threads events lat_avg lat_p95
  threads=$(grep 'Number of threads:' "$file" | grep -oE '[0-9]+' | head -1)
  events=$(grep 'events per second:' "$file" | grep -oE '[0-9]+\.[0-9]+' | head -1)
  lat_avg=$(grep -A5 'Latency (ms)' "$file" | grep 'avg:' | grep -oE '[0-9]+\.[0-9]+' | head -1)
  lat_p95=$(grep -A5 'Latency (ms)' "$file" | grep '95th percentile:' | grep -oE '[0-9]+\.[0-9]+' | head -1)
  echo "${label}_${threads}threads,events_per_second,$events,events/s" >> "$SUMMARY"
  echo "${label}_${threads}threads,latency_avg,$lat_avg,ms" >> "$SUMMARY"
  echo "${label}_${threads}threads,latency_p95,$lat_p95,ms" >> "$SUMMARY"
}

extract_memory() {
  local file="$1" label="$2"
  local throughput
  throughput=$(grep 'MiB/sec' "$file" | grep -oE '[0-9]+\.[0-9]+ MiB/sec' | grep -oE '[0-9]+\.[0-9]+' | head -1)
  echo "${label},throughput,$throughput,MiB/s" >> "$SUMMARY"
}

extract_cpu "$OUT_DIR/cpu_1thread.txt"    "cpu"
extract_cpu "$OUT_DIR/cpu_allthreads.txt" "cpu"
extract_memory "$OUT_DIR/memory_write.txt" "memory_write"
extract_memory "$OUT_DIR/memory_read.txt"  "memory_read"

# ─── Print summary ────────────────────────────────────────────────────────────
echo ""
echo "=== RESUMEN ($DEVICE_NAME) ==="
column -t -s',' "$SUMMARY"
echo ""
echo "Resultados completos en: $OUT_DIR"
