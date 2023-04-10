/**
  ******************************************************************************
  * @file    delay.c
  * @author  Josh Grant
  * @course  CE2812
  * @assign	  Lab 9: Round Robin Processing
  * @brief   This file contains delay methods that utilize timer 5
  ******************************************************************************
*/

#include <inttypes.h>
#include <stdio.h>
#include "delay.h"
#include "memoryDefs.h"

//Private function prototypes
static void delay(uint32_t ticks);
static void initializeTimer();

//Static variable to track if the buzzer is initialized
static uint8_t isTimerInitialized = 0;

//Static file constants for memory locations
static volatile RCC* const rcc = RCC_BASE;
static volatile TIMx* const tim5 = TIM5_BASE;


/*
 * method to delay a given amount of ms
 * inputs: the time to delay in ms
 * output: void
 */
void delayMs(uint32_t ms) {
	uint32_t ticks = ms*MS_MUL_FACTOR;
	delay(ticks);
}

/*
 * method to delay a given amount of us
 * inputs: the time to delay in us
 * output: void
 */
void delayUs(uint32_t us) {
	uint32_t ticks = us*US_MUL_FACTOR;
	delay(ticks);
}

/*
 * generic private helper method to delay a given amount clock ticks
 * inputs: the number of ticks to delay
 * output: void
 */
static void delay(uint32_t ticks) {
	//Make sure the timer gets initialized if it's not already
	if (!isTimerInitialized) {
		initializeTimer();
	}
	tim5->ARR = ticks;
	tim5->CNT = 0;
	tim5->CR1 |= TIM_EN;
	//Busy wait until timer is finished
	while (~(tim5->SR) & UIF);
	tim5->CR1 &= ~TIM_EN;
	tim5->SR &= ~UIF;
}

/*
 * method to initialize the timer
 * input: void
 * output: void
 */
static void initializeTimer() {
	rcc->APB1ENR |= TIM5EN;
	tim5->PSC = CLOCK_DIVIDER;
	isTimerInitialized = 1;
}
