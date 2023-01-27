/**
  ******************************************************************************
  * @file    buzzer.h
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 5: Play a Tune
  * @brief   This file contains function prototypes, macro definitions, enums,
  * 		 and lookup tables/constants for song generation and playing
  ******************************************************************************
*/

//Do not duplicatively define this header file
#ifndef BUZZER_H_
#define BUZZER_H_

#include "memoryDefs.h"

#define HALFFREQUENCY 8000000
#define SEPARATIONMS 20

//Enums are used to make it easier to setup different notes
typedef enum {C = 0, Csh = 1, D = 2, Dsh = 3, E = 4, F = 5, Fsh = 6, G = 7, Gsh = 8, A = 9, Ash = 10, B = 11, REST = 12, ESC = 13} Note;
typedef enum {Eighth = 0, Quarter = 1, Half = 2, Whole = 3, Double = 4} Duration;

//NoteInfo contains all the info to play a note
typedef struct {
	Note note;
	uint8_t octave;
	Duration duration;
} NoteInfo;

//Function prototypes
extern void playSong(const NoteInfo song[]);
extern void playSongInBackground(NoteInfo song[]);
extern void playNote(NoteInfo note);
void playFrequency(double frequency, uint32_t durationMs);

static const NoteInfo endNote = {ESC, 0, 0};

//Below are a couple songs
static const NoteInfo hotCrossBuns[] = {
		{E, 4, Half},
		{D, 4, Half},
		{C, 4, Whole},
		{E, 4, Half},
		{D, 4, Half},
		{C, 4, Whole},
		{C, 4, Quarter},
		{C, 4, Quarter},
		{C, 4, Quarter},
		{C, 4, Quarter},
		{D, 4, Quarter},
		{D, 4, Quarter},
		{D, 4, Quarter},
		{D, 4, Quarter},
		{E, 4, Half},
		{D, 4, Half},
		{C, 4, Whole},
		endNote
};

static const NoteInfo happyBirthday[] = {
		{C, 4, Quarter},
		{C, 4, Eighth},
		{D, 4, Half},
		{C, 4, Half},
		{F, 4, Half},
		{E, 4, Whole},
		{C, 4, Quarter},
		{C, 4, Eighth},
		{D, 4, Half},
		{C, 4, Half},
		{G, 4, Half},
		{F, 4, Whole},
		{C, 4, Quarter},
		{C, 4, Eighth},
		{C, 5, Half},
		{A, 4, Half},
		{F, 4, Half},
		{E, 4, Half},
		{D, 4, Whole},
		{A, 5, Eighth},
		{A, 5, Eighth},
		{A, 5, Half},
		{F, 4, Half},
		{G, 4, Half},
		{F, 4, Whole},
		endNote
};

#endif
