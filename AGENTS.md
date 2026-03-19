# AGENTS.md - HPC Matrix Multiplication Project

This repository contains C programs for benchmarking different approaches to matrix multiplication:
sequential, memory-optimized, threaded (pthreads), and multiprocess (fork).

## Build Commands

All source files are in `src/`. Compiled binaries should go in `output/`.

### Sequential
```bash
gcc src/SecuentialMatrixSolver.c -o output/secuential
```

### Memory-Optimized (cache-friendly access with -O3)
```bash
gcc src/MemoryMatrixSolver.c -O3 -o output/memory
```

### Threaded (pthreads)
```bash
gcc src/ThreadsMatrixSolver.c -o output/threads -lpthread
```

### Multiprocessing (fork)
```bash
gcc src/MultiprocessingMatrixSolver.c -o output/multiprocessing
```

### All-at-once (with warnings enabled)
```bash
gcc -Wall -Wextra src/SecuentialMatrixSolver.c -o output/secuential
gcc -Wall -Wextra -O3 src/MemoryMatrixSolver.c -o output/memory
gcc -Wall -Wextra src/ThreadsMatrixSolver.c -o output/threads -lpthread
gcc -Wall -Wextra src/MultiprocessingMatrixSolver.c -o output/multiprocessing
```

## Run Commands

All solvers take matrix dimensions as command-line arguments:
```bash
./output/secuential <rows> <cols>
```

Threaded and multiprocessing versions also accept parallelism count:
```bash
./output/threads <rows> <num_threads>
./output/multiprocessing <rows> <num_processes>
```

Example with 4x4 matrix:
```bash
./output/secuential 4 4
```

Output format is CSV-friendly: elapsed time in seconds with 6 decimal places followed by comma.
```bash
./output/secuential 4 4  # Output: 0.000123,
```

## Testing

There is no automated test framework. Manual verification is done via `test_3x3()` function.

To verify correctness:
1. Uncomment the `test_3x3();` call in `main()`
2. Recompile
3. Run with small matrix (e.g., `./output/secuential 3 3`)
4. Verify output matches expected result
5. Comment out `test_3x3();` again before benchmarking

The test uses fixed 3x3 matrices:
- A = [[1,2,3],[4,5,6],[7,8,9]]
- B = [[9,8,7],[6,5,4],[3,2,1]]
- Expected: C = A × B

## Code Style Guidelines

### Naming Conventions
- Use PascalCase for all function names: `CreateMatrix`, `FreeMatrix`, `MultiplyMatrices`
- Use camelCase for variables: `startRow`, `endRow`, `numThreads`
- Use PascalCase for structs: `ThreadArgs`, `ProcessArgs`
- Prefix globals with `g_` if needed (not used in this project)

### Brace Style
Use K&R style (opening brace on same line):
```c
void MyFunction() {
    if (condition) {
        doSomething();
    }
}
```

### C Standard
- Use C99 standard (`gcc -std=c99`)
- Use `int` for loop variables (C99 feature)
- Avoid VLA (Variable Length Arrays) - use heap allocation instead

### Includes
Order includes logically and add brief comments:
```c
#include <stdio.h>      // Standard input/output
#include <stdlib.h>     // Memory management, atoi, rand
#include <time.h>       // clock_gettime for wall-clock timing
#include <pthread.h>    // POSIX threads
#include <unistd.h>     // fork, getpid
#include <sys/wait.h>   // wait for child processes
#include <sys/mman.h>   // shared memory mmap
```

### Error Handling
Always check return values from allocation and system calls:
```c
int** matrix = (int**)malloc(rows * sizeof(int*));
if (!matrix) { perror("malloc failed (matrix rows)"); exit(1); }
```

For mmap, check for MAP_FAILED (not NULL):
```c
int* data = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_ANONYMOUS, -1, 0);
if (data == MAP_FAILED) { perror("mmap failed"); exit(1); }
```

Use `perror()` for system errors, `fprintf(stderr, ...)` for custom messages.

### Function Design
- Keep functions focused: one responsibility per function
- Maximum ~50 lines per function (excluding comments)
- Pass dimensions explicitly rather than relying on globals
- Document preconditions in comments for complex functions

### Thread/Process Safety
- Cap thread/process count to matrix rows to avoid empty workers
- Always join/join threads and wait for all child processes
- Use `pthread_join()` in a loop after all `pthread_create()` calls
- Use `wait(NULL)` in a loop after all `fork()` calls

### Performance Notes
- Use `clock_gettime(CLOCK_MONOTONIC, &ts)` for wall-clock timing
- Compute elapsed time like this:
```c
double elapsed = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;
```
- Prefer `MAP_SHARED` for mmap when child processes write to shared memory
- Memory-optimized version transposes matrix B for cache-friendly access

## Project Structure
```
src/
├── SecuentialMatrixSolver.c     # Basic sequential multiplication
├── MemoryMatrixSolver.c         # Cache-optimized (transposed B)
├── ThreadsMatrixSolver.c        # POSIX threads implementation
└── MultiprocessingMatrixSolver.c # Fork-based multiprocessing
output/                          # Compiled binaries (gitignored)
stats/                           # Timing results per machine
```

## Common Issues
- **Segmentation fault**: Check matrix allocation and free pairing
- **Wrong results**: Verify row/column indices in multiplication loops
- **Timing includes printing**: Comment out `print_matrix()` calls before benchmarking
- **Thread overhead dominant**: Use large matrices (1000+) for meaningful measurements
