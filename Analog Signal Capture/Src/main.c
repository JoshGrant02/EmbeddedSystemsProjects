/**
  ******************************************************************************
  * @file    main.c
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 7: Analog Signal Capture
  * @brief   This file contains a generic driver program to accept user commands
  * 		 from stdin and process them, including ones for digitizing waveform
  ******************************************************************************
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "consoleCommands.h"
#include "uart_driver.h"
#include "buzzer.h"
#include "frequencyReader.h"
#include "adc.h"

#define RMW_CMD "rmw"
#define WMW_CMD "wmw"
#define DMP_CMD "dm"
#define PS_CMD "ps"
#define PBS_CMD "pbs"
#define RF_CMD "rf"
#define DW_CMD "dw"
#define DWCS_CMD "dwcs"
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
		else if (strcmp(instruction, RF_CMD) == 0) {
			readFrequency();
		}
		else if (strcmp(instruction, HELP_CMD) == 0) {
			printHelp();
		}
		else if (strcmp(instruction, DW_CMD) == 0) {
			uint32_t sampleRate = strtoul(paramOne, NULL, 0);
			uint32_t numSamples = strtoul(paramTwo, NULL, 0);
			uint8_t statusCode = collectSamples(sampleRate, numSamples);
			//Print messages to the console for different status codes
			if (statusCode == S_SUCCESS) {
				printf("Sampling begun..\n");
				printf("Sampling will take about %.2fs\n", ((double)numSamples/sampleRate));
			}
			else if (statusCode == S_COLLECTING) {
				printf("Sampling is already in process. Cannot begin\n");
			}
			else if (statusCode == S_INVALIDPARAMS) {
				printf("Invalid function parameters\n");
			}
		}
		else if (strcmp(instruction, DWCS_CMD) == 0) {
			uint16_t* samples = retrieveSamples();
			//Prints either the samples, or an error message if samples are not ready
			if (samples == NULL) {
				printf("Sampling has either not been started or not finished\n");
			}
			else {
				uint32_t sampleNum = 0;
				uint8_t foundLastSample = 0;
				//Print until we reached the last sample
				while (!foundLastSample) {
					uint16_t sample = samples[sampleNum];
					//Checks for the sentinel end sample
					if (sample == END_SAMPLE) {
						foundLastSample = 1;
					}
					else {
						printf("%.2f ", convertToVolts(sample));
					}
					sampleNum++;
				}
				printf("\n");
			}
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
