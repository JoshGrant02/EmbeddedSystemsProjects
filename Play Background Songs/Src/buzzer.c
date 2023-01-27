/**
  ******************************************************************************
  * @file    buzzer.c
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 5: Play a Tune
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

static volatile RCC* const rcc = RCC_BASE;
static volatile TIMx* const tim3 = TIM3_BASE;
static volatile GPIOx* const gpiob= GPIOB_BASE;
static volatile uint32_t* const NVIC_ISER = (uint32_t*)0xE000E100;

//Const arrays are used as lookup tables for the noteInfo. endNote is escape note
static const double noteFrequencies[] = {16.35, 17.32, 18.35, 19.45, 20.60, 21.83, 23.12, 24.50, 25.96, 27.50, 29.14, 30.87};
static const double octaveMultipliers[] = {1, 2, 4, 8, 16, 32, 64, 128, 256};
static const uint32_t noteLengths[] = {55, 130, 280, 580, 1180};

static volatile NoteInfo* currentSong;
static volatile uint32_t currentNote;
static volatile uint32_t currentDuration;
static volatile uint32_t currentPauseDuration;
static volatile uint32_t isSongPlaying;

/*
 * method to play the entirety of a passed in song
 * noteInfo: an array with a song
 * output: void
 */
void playSong(const NoteInfo song[]) {
	uint32_t index = 0;
	//Iterate through every note in the song until the escape note is reached
	while (song[index].note != ESC) {
		playNote(song[index++]);
	}
}

/*
 * method to play the entirety of a passed in song using interrupts in the background
 * noteInfo: an array with a song
 * output: void
 */
void playSongInBackground(NoteInfo song[]) {
	if (!isBuzzerInitialized) {
		initializeBuzzer();
	}
	// Will be using interrupts, need to enable in NVIC
	NVIC_ISER[0] = 1<<29;

	// turn on interrupt for UIE
	tim3->DIER = 1;

	currentSong = song;
	currentNote = 0;
	isSongPlaying = 1;
	playNextBackgroundNote();
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

static void playNextBackgroundNote() {
	NoteInfo note = currentSong[currentNote];
	double frequency = noteFrequencies[note.note];
	frequency *= octaveMultipliers[note.octave];
	double halfPeriodTicks = HALFFREQUENCY/frequency;
	currentDuration = noteLengths[note.duration]*frequency/500;
	currentPauseDuration = currentDuration+SEPARATIONMS*frequency/500;

	tim3->ARR = halfPeriodTicks;
	tim3->CCR1 = halfPeriodTicks;
	tim3->CCER |= TIM_CC1E;
	tim3->CR1 |= TIM_EN;
}

static void stopBackgroundSong() {
	currentDuration = 0;
	currentPauseDuration = 0;
	currentNote = 0;
	isSongPlaying = 0;
	tim3->CCER |= TIM_CC1E;
	tim3->CR1 &= ~(TIM_EN);
	tim3->DIER = 0;
}

void TIM3_IRQHandler(void) {
	static uint32_t currentTicks = 0;
	currentTicks++;
	tim3->SR = 0;

	if (currentTicks == currentDuration) {
		tim3->CCER &= ~(TIM_CC1E);
	}
	else if (currentTicks == currentPauseDuration) {
		currentTicks = 0;
		currentNote++;

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
