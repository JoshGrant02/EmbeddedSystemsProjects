/**
  ******************************************************************************
  * @file    main.c
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 3: LCD Api
  * @brief   This file contains a generic driver program to test the LCD methods
  ******************************************************************************
*/

#include <stdio.h>
#include <stdlib.h>
#include "buzzer.h"

/*
 * This main method contains a trivial driver program to test the LCD API and
 * delay methods
 */
int main(void){
	playFrequency(1600, 3);

	//Never return
	for(;;){}

	return 0;
}

