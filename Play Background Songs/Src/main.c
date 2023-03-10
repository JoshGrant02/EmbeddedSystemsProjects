//This lab was a relatively easy one. A good amount of my code was able to be copied/reused for the new method.
//It was a little weird to think about how to organize my static variables, and I don't think I did it necessarily
//the best way, but it looks good enough to me, and I didn't have a lot of time to work on this lab. I cleaned
//up a couple other things from my previous lab as well regarding code organization, so I think it looks even more
//professional from that standpoint.

/**
  ******************************************************************************
  * @file    main.c
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 6: Play a Tune in the Background
  * @brief   This file contains a generic driver program to accept user commands
  * 		 from stdin and process them, include ones for playing songs
  ******************************************************************************
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "consoleCommands.h"
#include "uart_driver.h"
#include "buzzer.h"

#define RMW_CMD "rmw"
#define WMW_CMD "wmw"
#define DMP_CMD "dm"
#define PS_CMD "ps"
#define PBS_CMD "pbs"
#define HELP_CMD "help"
#define HOTCROSSBUNS "HotCrossBuns"
#define HAPPYBIRTHDAY "HappyBirthday"
#define F_CPU 16000000UL

//Method Prototypes
static void handleSongInstruction(char* song, short inBackground);

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
		instruction = strtok(instruction, "\n");
		paramOne = strtok(paramOne, "\n");
		paramTwo = strtok(paramTwo, "\n");

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
		else if (strcmp(instruction, PS_CMD) == 0) {
			handleSongInstruction(paramOne, 0);
		}
		else if (strcmp(instruction, PBS_CMD) == 0) {
			handleSongInstruction(paramOne, 1);
		}
		else if (strcmp(instruction, HELP_CMD) == 0) {
			printHelp();
		}
		else {
			printf("ERR: Invalid command. try again, or type \"help\" for help\n");
		}
	}

	return 0;
}

/*
 * This method is for handling the ps and pbs instructions
 *	song: the string for the song the user requested
 *	inBackground: a boolean short for toggling if the song should be run in the background
 */
static void handleSongInstruction(char* song, short inBackground) {
	Song songToPlay;
	//Check the song that is user input, and play it or print error message
	if (strcmp(song, HOTCROSSBUNS) == 0) {
		songToPlay = HotCrossBuns;
	}
	else if (strcmp(song, HAPPYBIRTHDAY) == 0) {
		songToPlay = HappyBirthday;
	}
	else {
		printf("ERR: Invalid song. Song options:\n\t"
				" - %s\n\t"
				" - %s\n\t",
				HOTCROSSBUNS,
				HAPPYBIRTHDAY);
		return;
	}
	//Play the song in the background or in time
	uint32_t failed = inBackground ? playSongInBackground(songToPlay) : playSong(songToPlay);
	//If the song method returned an error code (1), print that a song is already playing
	if (failed) {
		printf("ERR: A song is already playing\n");
	}
}
