CC = gcc
CFLAGS = -O2
SRC = src
OUT = output

all: $(OUT)/secuential

$(OUT):
	mkdir -p $(OUT)

$(OUT)/secuential: $(SRC)/SecuentialCellularAutomaton.c | $(OUT)
	$(CC) -o $@ $< -lm


clean:
	rm -rf $(OUT)
