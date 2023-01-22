//This lab, I believe, in a way, was a bit easier than some of the previous c
//labs. Aside from my issues with wmw, the other methods in this program
//were fairly easy to implement. Also, I can tell that I am getting better
//at seamlessly differentiating between pointers and values. On another note,
//learning a few methods to manipulate/parse strings along with scanning and
//printing was pretty cool.

/**
  ******************************************************************************
  * @file    main.c
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 4: Console Application
  * @brief   This file contains a generic driver program to accept user commands
  * 		 from stdin and process them
  ******************************************************************************
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "consoleCommands.h"
#include "uart_driver.h"

#define RMW_CMD "rmw"
#define WMW_CMD "wmw"
#define DMP_CMD "dm"
#define HELP_CMD "help"
#define F_CPU 16000000UL

/*
 * This main method contains a driver program to accept user commands from stdin
 * and process them
 */
int main(void){
	init_usart2(57600, F_CPU);
	//While loop infinitely loops, accepting a command and prompting for another one
	while (1) {
		printf("\n> ");
		char command[100];
		fgets(command, 100, stdin);
		char* instruction = strtok(command, " ");
		char* paramOne = strtok(NULL, " ");
		char* paramTwo = strtok(NULL, " ");

		//This conditional block determines what instruction to execute
		if (strcmp(instruction, RMW_CMD) == 0) {
			uint32_t* address = (uint32_t*) strtoul(paramOne, NULL, 0);
			readMemWord(address);
		}
		else if (strcmp(instruction, WMW_CMD) == 0) {
			uint32_t* address = (uint32_t*) strtoul(paramOne, NULL, 0);
			uint32_t data = strtoul(paramTwo, NULL, 0);
			writeMemWord(address, data);
		}
		else if (strcmp(instruction, DMP_CMD) == 0) {
			uint32_t* address = (uint32_t*) strtoul(paramOne, NULL, 0);
			uint32_t numBytes = strtoul(paramTwo, NULL, 0);
			//If the numBytes parameter is left empty or set to 0, override it to 16
			if (numBytes == 0) {
				dumpMemDefaultWidth(address);
			}
			else {
				dumpMem(address, numBytes);
			}
		}
		else if (!strcmp(instruction, HELP_CMD)) {
			printHelp();
		}
		else {
			printf("Invalid command. try again, or type \"help\" for help\n");
		}
	}

	return 0;
}

