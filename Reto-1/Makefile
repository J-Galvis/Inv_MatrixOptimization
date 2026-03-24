
CC = gcc
CFLAGS = -O2
SRC = src
OUT = output

all: $(OUT)/secuential $(OUT)/memory $(OUT)/threads $(OUT)/multiprocessing $(OUT)/secuentialFlags

$(OUT):
	mkdir -p $(OUT)

$(OUT)/secuential: $(SRC)/JacobiSecuential.c | $(OUT)
	$(CC) -Wall -lm -O0 -o $@ $<

$(OUT)/secuentialFlags: $(SRC)/JacobiSecuentialFlags.c | $(OUT)
	$(CC) $(CFLAGS) -Wall -lm -o $@ $<

$(OUT)/memory: $(SRC)/JacobiMemory.c | $(OUT)
	$(CC) -Wall -lm -O0 -o $@ $<

$(OUT)/threads: $(SRC)/JacobiThreads.c | $(OUT)
	$(CC) -Wall -lpthread -lm -O0 -o $@ $<

$(OUT)/multiprocessing: $(SRC)/JacobiMultiprocessing.c | $(OUT)
	$(CC) -Wall -lm -O0 -o $@ $<

clean:
	rm -rf $(OUT)
