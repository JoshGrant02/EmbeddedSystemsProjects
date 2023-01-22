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

//Static variable to track if the buzzer is initialized
static uint8_t isBuzzerInitialized = 0;

static volatile RCC* const rcc = RCC_BASE;
static volatile TIMx* const tim3 = TIM3_BASE;
static volatile GPIOx* const gpiob= GPIOB_BASE;

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
