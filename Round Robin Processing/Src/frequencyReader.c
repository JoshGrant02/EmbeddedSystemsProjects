/**
  ******************************************************************************
  * @file    buzzer.c
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 6: Read a frequency
  * @brief   This file contains method implementations to read a frequency
  ******************************************************************************
*/

#include <stdio.h>
#include <stdlib.h>
#include "memoryDefs.h"
#include "frequencyReader.h"

//Method Prototypes
static void initializeTimer();

//Static variable to track if the buzzer is initialized
static uint8_t isTimerInitialized = 0;

//Memory locatoins
static volatile RCC* const rcc = RCC_BASE;
static volatile TIMx* const tim2 = TIM2_BASE;
static volatile GPIOx* const gpioa = GPIOA_BASE;
static volatile uint32_t* const nvicIser = NVIC_ISER;

static volatile uint32_t numSamplesTaken;
static volatile uint32_t samplingFinished;
static volatile uint32_t longestSample;
static volatile uint32_t shortestSample;
static volatile uint32_t sampleSum;
static volatile uint32_t previousTimestamp;

/*
 * Method to read in a frequency from PA15 and report its frequency to the console
 * output: none
 */
void readFrequency() {
	//Make sure the timer gets initialized if it's not already
	if (!isTimerInitialized) {
		initializeTimer();
	}

	numSamplesTaken = 0;
	samplingFinished = 0;

	nvicIser[0] |= 1<<28;
	tim2->CR1 |= TIM_EN;
	tim2->DIER |= CC1IE;

	while (!samplingFinished);

	tim2->CR1 &= ~(TIM_EN);
	tim2->DIER &= ~(CC1IE);

	double averageSample = sampleSum/NUM_SAMPLES;
	double averageFrequency = 1/(averageSample*TICK_TIME);
	double smallestFrequency = 1/(longestSample*TICK_TIME);
	double biggestFrequency = 1/(shortestSample*TICK_TIME);

	printf("Average: %.3fhz\nSmallest: %.3fhz\nBiggest: %.3fhz\n", averageFrequency, smallestFrequency, biggestFrequency);
}

/*
 * IRQ handler to handle recording timestamps for the input frequency
 */
void TIM2_IRQHandler(void) {
	if (numSamplesTaken == NUM_SAMPLES+1) {
		samplingFinished = 1;
	}

	uint32_t timestamp = tim2->CCR1;
	uint32_t difference = timestamp - previousTimestamp;
	previousTimestamp = timestamp;

	//Give the interrupts a couple of samples to establish a consistent time
	if (numSamplesTaken > 1) {
		//First sample sets all of our values, subsequent ones update them
		if (numSamplesTaken == 2) {
			longestSample = difference;
			shortestSample = difference;
			sampleSum = difference;
		}
		else {
			shortestSample = difference < shortestSample ? difference : shortestSample;
			longestSample = difference > longestSample ? difference : longestSample;
			sampleSum += difference;
		}
	}

	numSamplesTaken++;
}

/*
 * method to initialize the timer
 * input: void
 * output: void
 */
static void initializeTimer() {
	rcc->AHB1ENR |= GPIOBEN;
	rcc->APB1ENR |= TIM2EN;
	gpioa->MODER |= AF_MODE<<MODER_PIN15;
	gpioa->AFRH |= AF1<<AF_PIN15;
	tim2->CCMR1 |= IC_CH1<<CC1S_PINS;
	tim2->CCER |= TIM_CC1E;
	tim2->ARR = MAX_ARR;
	isTimerInitialized = 1;
}

