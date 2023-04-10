//This lab was definitely an interesting one, and it is cool to see/understand
//that the way I have it implemented (your fancy version) allows for the
//creation of any number of tasks, where if I were to create another program, I
//could add it into this one. Ideally, I would've polished up some of my code
//from previous labs (the knightRiderLights code) to make it conform to my
//coding standards now that I know a lot more, but I was doing this pretty late
//last night, so I just wanted to make sure it worked and that I understood it.

/**
  ******************************************************************************
  * @file    main.c
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 9: Round Robin Processing
  * @brief   This file contains a driver program to setup round robin processing
  ******************************************************************************
*/

#include <stdio.h>
#include <stdlib.h>
#include "knightRiderLights.h"
#include "consoleApp.h"
#include "roundRobin.h"
#include "uart_driver.h"

//UART initialization constant
#define F_CPU 16000000UL

//Round robin values
#define NUM_TASKS 2
#define TASK_TICKS 20
#define STACK_SIZE 50

//Systick register locations
#define STK_CTRL (volatile uint32_t*) 0xE000E010
#define STK_LOAD (volatile uint32_t*) 0xE000E014
#define STK_VAL  (volatile uint32_t*) 0xE000E018

//Systick control values
#define ENABLE 1<<0
#define TICKINT 1<<1
#define CLOCKSRC 1<<2
#define COUNTFLAG 1<<16
#define ONE_MS 2000

//Static file constants for memory locations
static volatile uint32_t* const stkCtrl = STK_CTRL;
static volatile uint32_t* const stkLoad = STK_LOAD;

//Method prototypes
void SysTick_Handler(void);

/*
 * This main method sets up the round robin tasks and begins execution
 */
int main(void) {
	init_usart2(57600,F_CPU);

	init_tasker(NUM_TASKS, TASK_TICKS);
	init_task(1, STACK_SIZE, knightRiderLightsMain, TASK_TICKS);
	*stkLoad = ONE_MS;
	*stkCtrl |= (ENABLE|TICKINT);
	consoleAppMain();
}

/*
 * SysTick handler to handle ticking the round robin task every 1ms
 */
void SysTick_Handler(void)
{
	tasker_tick();
}
