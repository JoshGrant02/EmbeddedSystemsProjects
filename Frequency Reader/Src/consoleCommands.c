/**
  ******************************************************************************
  * @file    consoleCommands.c
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 4: Console Application
  * @brief   A file containing subroutines to read/write from/to memory using
  * 		 the console
  ******************************************************************************
*/

#include <stdio.h>
#include <string.h>
#include "consoleCommands.h"

/*
 * method to read a word from the given address and print it to the console
 * address: the address to read from
 * output: void
 */
void readMemWord(uint32_t* address) {
	//Conditional verifies that the address is on a word boundary
	if ((uint32_t) address % WORD_ALIGNMENT == 0) {
		uint32_t data = *address;
		printf("0x%08x: 0x%08x\t%u\n", address, data, data);
	}
	else {
		printf("ERROR: read address must be word-aligned\n");
	}
}


/*
 * method to write a given word to a given address
 * address: the address to write to
 * data: the word to write
 * output: void
 */
void writeMemWord(uint32_t* address, uint32_t data) {
	//Conditional verifies that the address is on a word boundary
	if ((uint32_t) address % WORD_ALIGNMENT == 0) {
		*address = data;
		printf("0x%08x: 0x%08x\t%u\n", address, data, data);
	}
	else {
		printf("ERROR: write address must be word-aligned\n");
	}

}


/*
 * method to dump (print) 16 bytes to the console beginning from the memory
 * address provided.
 * startingAddress: the starting memory address
 * output: void
 */
void dumpMemDefaultWidth(uint32_t* startingAddress) {
	dumpMem(startingAddress, DEFAULT_DUMP_WIDTH);
}


/*
 * method to dump (print) a specified amount of bytes to the console beginning
 * from the memory address provided.
 * startingAddress: the starting memory address
 * numBytes: the number of bytes to print
 * output: void
 */
void dumpMem(uint32_t* startingAddress, uint32_t numBytes) {
	//Conditional verifies that the address is on a word boundary
	if ((uint32_t) startingAddress % WORD_ALIGNMENT == 0) {
		uint8_t index = 0;
		//Loop until we have printed out at least the number of bytes requested
		while (index < numBytes) {
			printf("0x%08x:", ((uint32_t)startingAddress + index));
			//Print the 8 bytes for the line
			for (uint8_t byteNum = 0; byteNum < DEFAULT_DUMP_WIDTH; byteNum++) {
				uint8_t byte = *(uint32_t*)((uint32_t) startingAddress + index);
				printf(" %02x", byte);
				index++;
			}
			printf("\n");
		}
	}
	else {
		printf("ERROR: read address must be word-aligned\n");
	}
}


/*
 * method to print the help prompt to the console
 * inputs: void
 * output: void
 */
void printHelp() {
	printf("\nCommands:\n\n"
			"rmw address\n\t"
			"- Reads a word from the given memory address and prints it\n\t  to the console\n\n"
			"wmw address data\n\t"
			"- Writes a word to the given memory address\n\n"
			"dmp address numBytes\n\t"
			"- Prints the specified number of bytes (rounded up to the\n\t  nearest multiple of 16) "
			"to the console, read from the\n\t  given memory address\n\n"
			"ps songName\n\t"
			"- Plays the requested song on the speaker\n\n"
			"pbs songName\n\t"
			"- Plays the requested song on the speaker in the background\n\n"
			"rf\n\t"
			"- Reads the frequency of a square wave driven into pin PA15,\n\t  and prints the "
			"frequency to the console\n\n"
			"help\n\t"
			"- Prints this prompt\n");
}
