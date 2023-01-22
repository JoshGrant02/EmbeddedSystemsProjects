
#ifndef CONSOLE_COMMANDS_H_
#define CONSOLE_COMMANDS_H_

#define DEFAULT_DUMP_WIDTH 16

//Function Prototypes
extern void readMemWord(uint32_t* address);
extern void writeMemWord(uint32_t* address, uint32_t data);
extern void dumpMemDefault(uint32_t* startingAddress);
extern void dumpMem(uint32_t* startingAddress, uint32_t length);
extern void printHelp();

#endif
