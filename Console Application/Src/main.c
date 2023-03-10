/**
  ******************************************************************************
  * @file    main.c
  * @author  Auto-generated by STM32CubeIDE
  * @version V1.0
  * @brief   Default main function.
  ******************************************************************************
*/



#include <stdio.h>
#include <string.h>
#include "consoleCommands.h"
#include "uart_driver.h"
#define RMW_CMD "rmw"
#define WMW_CMD "wmw"
#define DMP_CMD "dm"
#define HELP_CMD "help"
#define F_CPU 16000000UL

// main
int main(void){
	init_usart2(57600, F_CPU);
	while (1) {
		printf("> ");
		char* command;
		fgets(command, 100, stdin);
		char* instruction = strtok(command, " ");
		char* paramOne;
		char* paramTwo;
		if (strcmp(instruction, RMW_CMD)) {
			paramOne = strtok(NULL, " ");
			uint32_t address = strtol(paramOne, NULL, 0);
			readMemWord(address);
		}
		else if (strcmp(instruction, WMW_CMD) == 0) {
			paramOne = strtok(NULL, " ");
			paramTwo = strtok(NULL, " ");
			uint32_t address = strtol(paramOne, NULL, 0);
			uint32_t data = strtol(paramTwo, NULL, 0);
			writeMemWord(address, data );
		}
		else if (strcmp(instruction, DMP_CMD) == 0) {
			paramOne = strtok(NULL, " ");
			paramTwo = strtok(NULL, " ");
			uint32_t address = strtol(paramOne, NULL, 0);
			uint32_t data = strtol(paramTwo, NULL, 0);
			dumpMem(address, data);
		}
		else if (strcmp(instruction, HELP_CMD) == 0) {
			printHelp();
		}
	}

	// never return
	for(;;){}

	return 0;
}

