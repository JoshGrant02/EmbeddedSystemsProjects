//This lab, I kind of went a little crazy with memory definitions. I didn't get
//enough time to completely finish my header files, but I will hopefully be able
//to easily use them and flesh them out in future labs. This was a really fun
//lab though because I tried to make my song playing with multiple levels of
//abstraction and I used enums to define the notes and octaves. If I have time
//over this weekend, or just in the future, I definitely will be returning to
//this lab in my free time to add musical freedom, e.g. adding tempos, more note
//lengths (the ones with the dots or whatever), more songs, make the lower
//octaves actually work (I know in current state, my arr value will overflow and
//it won't properly play the note, but I am ignoring that issue for this lab
//submission, because the different octaves wasn't a requirement). This was a
//fun lab though and I also feel like I actually wrote semi-industry standard
//looking code with all the tools we learned in the past weeks and that I was
//able to implement. :)

/**
  ******************************************************************************
  * @file    main.c
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 5: Play a Tune
  * @brief   This file contains a generic driver program to accept user commands
  * 		 from stdin and process them, include one for playing songs
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
#define SONG_CMD "song"
#define HELP_CMD "help"
#define HOTCROSSBUNS "HotCrossBuns"
#define HAPPYBIRTHDAY "HappyBirthday"
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
		else if (strcmp(instruction, SONG_CMD) == 0) {
			//Check the song that is user input, and play it or print error message
			if (strcmp(paramOne, HOTCROSSBUNS) == 0) {
				playSong(hotCrossBuns);
			}
			else if (strcmp(paramOne, HAPPYBIRTHDAY) == 0) {
				playSong(happyBirthday);
			}
			else {
				printf("Invalid song. Song options:\n\t"
						" - %s\n\t"
						" - %s\n\t",
						HOTCROSSBUNS,
						HAPPYBIRTHDAY);
			}
		}
		else if (strcmp(instruction, HELP_CMD) == 0) {
			printHelp();
		}
		else {
			printf("Invalid command. try again, or type \"help\" for help\n");
		}
	}

	return 0;
}

