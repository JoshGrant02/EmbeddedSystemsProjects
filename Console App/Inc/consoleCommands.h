/**
  ******************************************************************************
  * @file    consoleCommands.h
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 4: Console Application
  * @brief   A file containing function prototypes and relevant macros for the
  * 		 console commands
  ******************************************************************************
*/

//Do not duplicatively define this header file
#ifndef CONSOLE_COMMANDS_H_
#define CONSOLE_COMMANDS_H_

#define DEFAULT_DUMP_WIDTH 16
#define WORD_ALIGNMENT 4

//Function Prototypes
extern void readMemWord(uint32_t* address);
extern void writeMemWord(uint32_t* address, uint32_t data);
extern void dumpMemDefaultWidth(uint32_t* startingAddress);
extern void dumpMem(uint32_t* startingAddress, uint32_t numBytes);
extern void printHelp();

#endif
