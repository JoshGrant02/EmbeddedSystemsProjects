

#include <stdio.h>
#include <string.h>
#include "consoleCommands.h"

void readMemWord(uint32_t* address) {
	uint32_t data = *address;
	printf("%x: %x %u", address, data, data);
}


void writeMemWord(uint32_t* address, uint32_t word) {
	*address = word;
}


void dumpMemDefault(uint32_t* startingAddress) {
	dumpMem(startingAddress, DEFAULT_DUMP_WIDTH);
}


void dumpMem(uint32_t* startingAddress, uint32_t length) {
	uint8_t index = 0;
	while (index*4 < length) {
		uint32_t firstWord = *(startingAddress + index);
		uint32_t secondWord = *(startingAddress + index + 1);
		uint32_t thirdWord = *(startingAddress + index + 2);
		uint32_t fourthWord = *(startingAddress + index + 3);

		index += 4;
	}

}


void printHelp() {
	printf("Help");
}
