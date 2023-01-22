//In this lab, it was interesting to see how I could write the lcd api with
//significantly fewer lines of code using c than arm. Additionally, sprintf
//was a lifesaver because that made it really easy to parse a decimal int
//into a string to print, rather than having to do the double dabble algorithm.
//Grasping the concept of pointers and passing by reference vs passing by value
//has been a little interesting, but it is just a very new topic to me and I am
//getting more used to it. I feel like C has a lot of semi-niche logic things
//(e.g. pointer addition) that I have to take a little bit of time to get used
//to, but once I do, they will probably be very convenient when programming.

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
#include "lcd.h"
#include "delay.h"
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

