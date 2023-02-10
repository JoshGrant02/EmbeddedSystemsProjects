/**
  ******************************************************************************
  * @file    buzzer.c
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 6: Play a Tune in the Background
  * @brief   This file contains method implementations for playing songs on the
  * 		 buzzer
  ******************************************************************************
*/

#include <stdio.h>
#include <stdlib.h>
#include "buzzer.h"
#include "delay.h"

//Method Prototypes
static void initializeBuzzer();
static void playNextBackgroundNote();
static void stopBackgroundSong();

//Static variable to track if the buzzer is initialized
static uint8_t isBuzzerInitialized = 0;

//Memory locatoins
static volatile RCC* const rcc = RCC_BASE;
static volatile TIMx* const tim3 = TIM3_BASE;
static volatile GPIOx* const gpiob= GPIOB_BASE;
static volatile uint32_t* const nvicIser = NVIC_ISER;

//Const arrays are used as lookup tables for the noteInfo. endNote is escape note
static const double noteFrequencies[] = {16.35, 17.32, 18.35, 19.45, 20.60, 21.83, 23.12, 24.50, 25.96, 27.50, 29.14, 30.87};
static const double octaveMultipliers[] = {1, 2, 4, 8, 16, 32, 64, 128, 256};
static const uint32_t noteLengths[] = {55, 130, 280, 580, 1180};
static const NoteInfo endNote = {ESC, 0, 0};

//Variables for tracking and playing background music
static volatile NoteInfo* currentSong;
static volatile uint32_t currentNote;
static volatile uint32_t currentNoteDuration;
static volatile uint32_t currentPauseDuration;
static volatile uint32_t isSongPlaying;

//Below are a couple songs
static NoteInfo hotCrossBuns[] = {
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

static NoteInfo happyBirthday[] = {
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

/*
 * method to play the entirety of a passed in song
 * noteInfo: an array with a song
 * output: 0 if song played, 1 if buzzer is busy
 */
uint32_t playSong(const Song song) {
	//Returns if a song is already playing
	if (isSongPlaying) {
		return 1;
	}
	NoteInfo* notes;
	//Determines the song to play
	if (song == HappyBirthday) {
		notes = happyBirthday;
	}
	else if (song == HotCrossBuns) {
		notes = hotCrossBuns;
	}

	uint32_t index = 0;
	//Iterate through every note in the song until the escape note is reached
	while (notes[index].note != ESC) {
		playNote(notes[index++]);
	}
	return 0;
}

/*
 * method to play the entirety of a passed in song using interrupts in the background
 * noteInfo: an array with a song
 * output: 0 if song was started, 1 if buzzer is busy
 */
uint32_t playSongInBackground(Song song){
	//Returns if a song is already playing
	if (isSongPlaying) {
		return 1;
	}
	//Make sure the buzzer gets initialized if it's not already
	if (!isBuzzerInitialized) {
		initializeBuzzer();
	}
	// Will be using interrupts, need to enable in NVIC
	nvicIser[0] = 1<<29;

	// turn on interrupt for UIE
	tim3->DIER = 1;

	if (song == HappyBirthday) {
		currentSong = happyBirthday;
	}
	else if (song == HotCrossBuns) {
		currentSong = hotCrossBuns;
	}
	currentNote = 0;
	isSongPlaying = 1;
	playNextBackgroundNote();
	return 0;
}

/*
 * method to play a single note
 * note: the note to play
 * output: void
 */
void playNote(NoteInfo note) {
	//Delay or play a note depending on if it is a rest or not
	if (note.note == REST) {
		delay_ms(noteLengths[note.duration]+SEPARATIONMS);
	}
	else {
		double frequency = noteFrequencies[note.note];
		frequency *= octaveMultipliers[note.octave];

		playFrequency(frequency, noteLengths[note.duration]);
		delay_ms(SEPARATIONMS);
	}
}

/*
 * method to send a frequency to the buzzer
 * frequency: the desired frequency to send to the buzzer
 * durationMs: the amount of Ms to play the frequency for
 * output: void
 */
void playFrequency(double frequency, uint32_t durationMs) {
	//Make sure the buzzer gets initialized the first time this method is invoked
	if (!isBuzzerInitialized) {
		initializeBuzzer();
	}

	double halfPeriodTicks = HALFFREQUENCY/frequency;

	tim3->ARR = halfPeriodTicks;
	tim3->CCR1 = halfPeriodTicks;
	tim3->CR1 |= TIM_EN;

	delay_ms(durationMs);

	tim3->CR1 &= ~(TIM_EN);
}

/*
 * method to play the next note in the stored background song
 * output: none
 */
static void playNextBackgroundNote() {
	NoteInfo note = currentSong[currentNote];
	double frequency = noteFrequencies[note.note];
	frequency *= octaveMultipliers[note.octave];
	double halfPeriodTicks = HALFFREQUENCY/frequency;
	currentNoteDuration = noteLengths[note.duration]*frequency/HALFSTOMS;
	currentPauseDuration = currentNoteDuration+SEPARATIONMS*frequency/HALFSTOMS;

	tim3->ARR = halfPeriodTicks;
	tim3->CCR1 = halfPeriodTicks;
	tim3->CCER |= TIM_CC1E;
	tim3->CR1 |= TIM_EN;
}

/*
 * method to stop playing the current background song
 * output: none
 */
static void stopBackgroundSong() {
	currentNoteDuration = 0;
	currentPauseDuration = 0;
	currentNote = 0;
	isSongPlaying = 0;
	tim3->CCER |= TIM_CC1E;
	tim3->CR1 &= ~(TIM_EN);
	tim3->DIER = 0;
}

/*
 * IRQ handler to handle progressing through the notes in a background song
 */
void TIM3_IRQHandler(void) {
	static uint32_t currentTicks = 0;
	currentTicks++;
	tim3->SR = 0;

	//Checks if it is time pause the buzzer between notes or progress to the next note
	if (currentTicks == currentNoteDuration) {
		tim3->CCER &= ~(TIM_CC1E);
	}
	else if (currentTicks == currentPauseDuration) {
		currentTicks = 0;
		currentNote++;

		//If the song is over, then stop; otherwise, trigger the next note
		if (currentSong[currentNote].note != ESC) {
			playNextBackgroundNote();
		}
		else {
			stopBackgroundSong();
		}
	}
}

/*
 * method to initialize the buzzer
 * input: void
 * output: void
 */
static void initializeBuzzer() {
	rcc->AHB1ENR |= GPIOBEN;
	rcc->APB1ENR |= TIM3EN;
	gpiob->MODER |= AF_MODE<<MODER_PIN4;
	gpiob->AFRL |= AF2<<AF_PIN4;
	tim3->CCER |= TIM_CC1E;
	tim3->CCMR1 |= OC_TOGGLE<<OC1M_PINS;
	isBuzzerInitialized = 1;
}
