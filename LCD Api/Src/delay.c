/**
  ******************************************************************************
  * @file    delay.c
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 3: LCD Api
  * @brief   This file contains a delay methods that utilize the systick timer
  ******************************************************************************
*/

#include <inttypes.h>
#include <stdio.h>
#include "delay.h"

//Private function prototypes
static void delay(uint32_t ticks);

//Static file constants for memory locations
static volatile uint32_t* const stkCtrl = STK_CTRL;
static volatile uint32_t* const stkLoad = STK_LOAD;
static volatile uint32_t* const stkVal = STK_VAL;

/*
 * method to delay a given amount of ms
 * inputs: the time to delay in ms
 * output: void
 */
void delay_ms(uint32_t ms) {
	uint32_t ticks = ms*MS_MUL_FACTOR;
	delay(ticks);
}

/*
 * method to delay a given amount of us
 * inputs: the time to delay in us
 * output: void
 */
void delay_us(uint32_t us) {
	uint32_t ticks = us*US_MUL_FACTOR;
	delay(ticks);
}

/*
 * generic private helper method to delay a given amount clock ticks
 * inputs: the number of ticks to delay
 * output: void
 */
static void delay(uint32_t ticks) {
	*stkLoad = ticks;
	*stkVal = 0;
	*stkCtrl |= (ENABLE);
	//Busy wait until timer is finished
	while (~*stkCtrl & COUNTFLAG);
	*stkCtrl &= ~(COUNTFLAG|ENABLE);
}
