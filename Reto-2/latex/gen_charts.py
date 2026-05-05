#!/usr/bin/env python3
"""
gen_charts.py  —  Genera las gráficas del Reto-2 (Autómata Celular con OpenMP)

Reads the CSV timing files from stats/ and produces two PNG charts:
  1. charts/timing_comparison.png  — execution time vs N (log-log)
  2. charts/speedup_comparison.png — speedup vs N
"""

import os
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import numpy as np

# ── Paths ────────────────────────────────────────────────────────────────────
SCRIPT_DIR  = os.path.dirname(os.path.abspath(__file__))
STATS_DIR   = os.path.join(SCRIPT_DIR, '..', 'stats',
                           'Mac-mini-de-Daniel.local', '20260503_230658.done')
CHARTS_DIR  = os.path.join(SCRIPT_DIR, 'charts')
os.makedirs(CHARTS_DIR, exist_ok=True)

# Road sizes (N) used in the benchmark
N_VALUES = [10000, 25000, 50000, 75000, 100000, 125000,
            150000, 175000, 200000, 225000, 250000, 275000, 300000]

# ── Helper: parse a CSV file (comma-separated values, one run per line) ──────
def parse_csv(filepath):
    """Return a list of lists, one inner list per non-empty line."""
    runs = []
    with open(filepath) as fh:
        for line in fh:
            line = line.strip().rstrip(',')
            if not line:
                continue
            values = [float(v) for v in line.split(',') if v.strip()]
            if values:
                runs.append(values)
    return runs

def averages(runs):
    """Column-wise average across all runs."""
    arr = np.array(runs)
    return arr.mean(axis=0)

# ── Load data ─────────────────────────────────────────────────────────────────
runs_seq  = parse_csv(os.path.join(STATS_DIR, 'secuential.csv'))
runs_par  = parse_csv(os.path.join(STATS_DIR, 'parallel.csv'))
runs_mem  = parse_csv(os.path.join(STATS_DIR, 'memory.csv'))

avg_seq = averages(runs_seq)
avg_par = averages(runs_par)
avg_mem = averages(runs_mem)

speedup_par = avg_seq / avg_par
speedup_mem = avg_seq / avg_mem

N = np.array(N_VALUES)

# ── Style ─────────────────────────────────────────────────────────────────────
plt.rcParams.update({
    'font.family': 'DejaVu Sans',
    'font.size': 11,
    'axes.titlesize': 13,
    'axes.labelsize': 12,
    'legend.fontsize': 10,
    'axes.grid': True,
    'grid.alpha': 0.35,
    'figure.dpi': 150,
})

COLORS = {'seq': '#e15759', 'par': '#4e79a7', 'mem': '#f28e2b'}
MARKERS = {'seq': 'o', 'par': 's', 'mem': '^'}

# ── Chart 1: Execution time comparison ────────────────────────────────────────
fig, ax = plt.subplots(figsize=(9, 5.5))

ax.loglog(N, avg_seq, color=COLORS['seq'], marker=MARKERS['seq'],
          linewidth=2, markersize=6, label='Secuencial')
ax.loglog(N, avg_par, color=COLORS['par'], marker=MARKERS['par'],
          linewidth=2, markersize=6, label='Paralelo (OpenMP)')
ax.loglog(N, avg_mem, color=COLORS['mem'], marker=MARKERS['mem'],
          linewidth=2, markersize=6, label='Memoria + OpenMP')

ax.set_xlabel('Longitud de carretera N (celdas)')
ax.set_ylabel('Tiempo de ejecución (s)')
ax.set_title('Comparación de tiempos de ejecución — Mac Mini M4')

# Nice N-axis labels
ax.xaxis.set_major_formatter(ticker.FuncFormatter(
    lambda x, _: f'{int(x):,}'.replace(',', '.')))
ax.xaxis.set_minor_formatter(ticker.NullFormatter())
ax.set_xticks(N)
ax.set_xticklabels([f'{v//1000}k' for v in N], rotation=45, ha='right')

ax.legend(loc='upper left')
plt.tight_layout()
plt.savefig(os.path.join(CHARTS_DIR, 'timing_comparison.png'), bbox_inches='tight')
plt.close()
print("  -> charts/timing_comparison.png  generada")

# ── Chart 2: Speedup comparison ───────────────────────────────────────────────
fig, ax = plt.subplots(figsize=(9, 5.5))

ax.plot(N, speedup_par, color=COLORS['par'], marker=MARKERS['par'],
        linewidth=2, markersize=6, label='Paralelo (OpenMP) vs Secuencial')
ax.plot(N, speedup_mem, color=COLORS['mem'], marker=MARKERS['mem'],
        linewidth=2, markersize=6, label='Memoria + OpenMP vs Secuencial')
ax.axhline(y=1, color='gray', linestyle='--', linewidth=1, alpha=0.6, label='Speedup = 1 (referencia)')

ax.set_xlabel('Longitud de carretera N (celdas)')
ax.set_ylabel('Speedup $S = T_{seq} / T_{par}$')
ax.set_title('Speedup relativo al secuencial — Mac Mini M4')
ax.set_xticks(N)
ax.set_xticklabels([f'{v//1000}k' for v in N], rotation=45, ha='right')
ax.set_ylim(bottom=0)
ax.yaxis.set_major_locator(ticker.MultipleLocator(0.5))

ax.legend(loc='lower right')
plt.tight_layout()
plt.savefig(os.path.join(CHARTS_DIR, 'speedup_comparison.png'), bbox_inches='tight')
plt.close()
print("  -> charts/speedup_comparison.png  generada")

print("\nDatos de resumen:")
print(f"{'N':>8}  {'Seq(s)':>10}  {'Par(s)':>10}  {'Mem(s)':>10}  {'SpPar':>7}  {'SpMem':>7}")
for i, n in enumerate(N):
    print(f"{n:>8,}  {avg_seq[i]:>10.4f}  {avg_par[i]:>10.4f}  {avg_mem[i]:>10.4f}"
          f"  {speedup_par[i]:>7.2f}  {speedup_mem[i]:>7.2f}")
