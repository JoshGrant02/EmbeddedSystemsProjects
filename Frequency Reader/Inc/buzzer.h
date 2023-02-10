/**
  ******************************************************************************
  * @file    buzzer.h
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 6: Play a Tune in the Background
  * @brief   This file contains function prototypes, macro definitions, enums,
  * 		 and lookup tables/constants for song generation and playing
  ******************************************************************************
*/

//Do not duplicatively define this header file
#ifndef BUZZER_H_
#define BUZZER_H_

#include "memoryDefs.h"

#define HALFFREQUENCY 8000000
#define HALFSTOMS 500
#define SEPARATIONMS 20

//Enums are used to make it easier to setup different notes
typedef enum {HotCrossBuns, HappyBirthday} Song;
typedef enum {C, Csh, D, Dsh, E, F, Fsh, G, Gsh, A, Ash, B, REST, ESC} Note;
typedef enum {Eighth, Quarter, Half, Whole, Double} Duration;

//NoteInfo contains all the info to play a note
typedef struct {
	Note note;
	uint8_t octave;
	Duration duration;
} NoteInfo;

//Function prototypes
extern uint32_t playSong(Song song);
extern uint32_t playSongInBackground(Song song);
extern void playNote(NoteInfo note);
void playFrequency(double frequency, uint32_t durationMs);

#endif
