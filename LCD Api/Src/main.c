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

#define TWO_SECONDS_IN_MS 2000
#define THREE_SECONDS_IN_MS 3000
#define ASCII_A 65
#define SECOND_ROW 1
#define SIXTH_COLUMN 5
#define FOURTH_COLUMN 3

/*
 * This main method contains a trivial driver program to test the LCD API and
 * delay methods
 */
int main(void){
	lcd_init();
	lcd_print_string("This is random");
	delay_ms(TWO_SECONDS_IN_MS);
	lcd_set_position(SECOND_ROW, SIXTH_COLUMN);
	lcd_print_string("Letter A:");
	lcd_print_char(ASCII_A);
	delay_ms(THREE_SECONDS_IN_MS);
	lcd_set_position(SECOND_ROW, SIXTH_COLUMN);
	lcd_print_string("Number:");
	lcd_print_num(1234);
	delay_ms(THREE_SECONDS_IN_MS);
	lcd_home();
	lcd_print_string("I'm back home :)");
	delay_ms(TWO_SECONDS_IN_MS);
	lcd_set_position(SECOND_ROW, FOURTH_COLUMN);
	lcd_print_string("Time to clear");
	delay_ms(TWO_SECONDS_IN_MS);
	lcd_clear();
	//Never return
	for(;;){}

	return 0;
}

