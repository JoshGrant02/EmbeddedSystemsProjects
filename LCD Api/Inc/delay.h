/**
  ******************************************************************************
  * @file    delay.h
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 3: LCD Api
  * @brief   This file has function prototypes and defined values for busy delay
  ******************************************************************************
*/

//Do not duplicatively define this header file
#ifndef DELAY_H_
#define DELAY_H_

#include <inttypes.h>

//Systick register locations
#define STK_CTRL (volatile uint32_t*) 0xE000E010
#define STK_LOAD (volatile uint32_t*) 0xE000E014
#define STK_VAL  (volatile uint32_t*) 0xE000E018

//Systick control values
#define ENABLE 1<<0
#define CLOCKSRC 1<<2
#define COUNTFLAG 1<<16

//Time tracking constants
#define MS_MUL_FACTOR 2000
#define US_MUL_FACTOR 2

extern void delay_ms(uint32_t ms);
extern void delay_us(uint32_t us);

#endif
