CC = gcc
CFLAGS = -Wall -O2
SRC = src
OUT = output

all: $(OUT)/secuential $(OUT)/memory $(OUT)/threads $(OUT)/multiprocessing

$(OUT):
	mkdir -p $(OUT)

$(OUT)/secuential: $(SRC)/SecuentialMatrixSolver.c | $(OUT)
	$(CC) $(CFLAGS) -o $@ $<

$(OUT)/memory: $(SRC)/MemoryMatrixSolver.c | $(OUT)
	$(CC) $(CFLAGS) -pthread -o $@ $<

$(OUT)/threads: $(SRC)/ThreadsMatrixSolver.c | $(OUT)
	$(CC) $(CFLAGS) -pthread -o $@ $<

$(OUT)/multiprocessing: $(SRC)/MultiprocessingMatrixSolver.c | $(OUT)
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -rf $(OUT)
