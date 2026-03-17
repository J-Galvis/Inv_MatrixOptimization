#!/bin/bash
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

DEVICE_NAME=$(hostname)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
STATS_BASE="$ROOT_DIR/stats/$DEVICE_NAME"
STATS_DIR="$STATS_BASE/$TIMESTAMP"

mkdir -p "$ROOT_DIR/output"
mkdir -p "$STATS_DIR"

sizes=(500 1000 2000 3000 5000 10000 15000 20000)
num_proccesses=(2 4) 

SECUENTIAL_FILE="$STATS_DIR/secuential.csv"

MEMORY_FILE="$STATS_DIR/memory.csv"

THREAD_FILE="$STATS_DIR/threads"

MULTIPROCESSING_FILE="$STATS_DIR/mutiprocessing"

echo "Secuential testing in process ..."

for j in {1..10}; do
  for i in "${sizes[@]}"; do
    "$ROOT_DIR/output/secuential" $i >>"$SECUENTIAL_FILE"
  done
  echo "" >>"$SECUENTIAL_FILE"
done

echo "Memory testing in process ..."

for j in {1..10}; do
  for i in "${sizes[@]}"; do
    "$ROOT_DIR/output/memory" $i >>"$MEMORY_FILE"
  done
  echo "" >>"$MEMORY_FILE"
done

echo "Threads testing in process ..."

COUNT=0
for n in "${num_proccesses[@]}"; do
  echo "Threads for $n testing in process ..."
  for j in {1..10}; do
    for i in "${sizes[@]}"; do
      "$ROOT_DIR/output/threads" $i $n >>"$THREAD_FILE${num_proccesses[$COUNT]}.csv"
    done
    echo "" >>"$THREAD_FILE${num_proccesses[$COUNT]}.csv"
  done
  ((COUNT++))
done

echo "Multiprocessing testing in process ..."

COUNT=0
for n in "${num_proccesses[@]}"; do
  echo "Multiprocessing for $n testing in process ..."
  for j in {1..10}; do
    for i in "${sizes[@]}"; do
      "$ROOT_DIR/output/multiprocessing" $i $n >>"$MULTIPROCESSING_FILE${num_proccesses[$COUNT]}.csv"
    done
    echo "" >>"$MULTIPROCESSING_FILE${num_proccesses[$COUNT]}.csv"
  done
  ((COUNT++))
done

echo "Listo! Los resultados se han guardado exitosamente"
