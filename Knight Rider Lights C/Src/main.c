/*
 * This lab was a lot easier than the night rider lights lab from last quarter if
 * I am remembering correctly. There were some things that I had some slight issues
 * with just because this was my first time actual coding in C, but I was able to
 * get the lab done relatively quickly. Accessing ports on the board is a lot easier
 * by just dereferencing the pointer, rather than having to worry about using the
 * correct ldr/str instruction. Definitely more readable than assembly and easier to
 * code, but I can see how if there isn't optimizations, some of the things that I
 * wrote could've been written more simplified in assembly. One last thing, using
 * multiple bitwise operators in one line of code is a lot easier than writing 5
 * different assembly instructions to do the same thing.
 */

/**
  ******************************************************************************
  * @file    main.c
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 1: Knight Rider Lights
  * @brief   Outputs a Night Rider Lights show to the LEDs
  ******************************************************************************
*/

#include <stdio.h>
#include "uart_driver.h"
#include <stdlib.h>

//UART initialization constant
#define F_CPU 16000000UL

//Board memory locations
#define AHB1ENR 0x40023830
#define MODER 0x40020400
#define ODR 0x40020414

//Moder mask values
#define OUTPUT_MODE_CLEAR_MASK 0xFF3FFC00
#define OUTPUT_MODE_SET_MASK 0x55155400

//Odr mask values
#define BOTTOM_HALF_LEDS 0x3F
#define TOP_HALF_LEDS 0x3C0
#define BOTTOM_HALF_SHIFT 5
#define TOP_HALF_SHIFT 6
#define LEDS_CLEAR_MASK 0x1F7E0

//ASCII values
#define ASCII_NUMBER_OFFSET 48
#define ASCII_CR 13

//Function Prototypes
void light_LED_init(void);
void light_LED(uint32_t number);
void delay_100ms(void);

/*
 * Main method to initialize all the components and then create
 * Knight Rider Lights effect on the LED. Also prints the number
 * of loops to the UART.
 */
int main(void){
	init_usart2(57600,F_CPU);
	light_LED_init();
	uint32_t numLoops = 0;

	uint32_t ledValue = (1<<9);
	light_LED(ledValue);
	delay_100ms();
	//Infinite loop to loop the light back and forth
	while (1) {
		//For loop to traverse the light to the right
		for (int i = 0; i < 9; i++) {
			ledValue = ledValue >> 1;
			light_LED(ledValue);
			delay_100ms();
		}
		//For loop to traverse the light to the left
		for (int i = 0; i < 9; i++) {
			ledValue = ledValue << 1;
			light_LED(ledValue);
			delay_100ms();
		}
		numLoops++;
		printf("System has completed %d loops\n\r", numLoops);
	}
	return 0;
}

/*
 * LED initialization method
 * inputs: void
 * output: void
 */
void light_LED_init(void) {
	uint32_t* ahbenr = (uint32_t*) AHB1ENR;
	uint32_t ahbenrValue = *ahbenr;
	ahbenrValue |= (1<<1);
	*ahbenr = ahbenrValue;

	uint32_t* moder = (uint32_t*) MODER;
	uint32_t moderValue = *moder;
	moderValue &= ~OUTPUT_MODE_CLEAR_MASK;
	moderValue |= OUTPUT_MODE_SET_MASK;
	*moder = moderValue;
}

/*
 * LED light
 * inputs: number-the number to push onto the LEDs
 * output: void
 */
void light_LED(uint32_t number) {
	uint32_t bottomHalf = (number & BOTTOM_HALF_LEDS) << BOTTOM_HALF_SHIFT;
	uint32_t topHalf = (number & TOP_HALF_LEDS) << TOP_HALF_SHIFT;

	uint32_t* odr = (uint32_t*) ODR;
	uint32_t value = *odr;

	//Clear the 0s we don't want, then set the 1s
	value &= ~(LEDS_CLEAR_MASK);
	value |= bottomHalf | topHalf;

	*odr = value;
}

/*
 * A busy delay function to delay 100ms
 * inputs: void
 * output: void
 */
void delay_100ms(void) {
	//This is a no-op for loop to busy delay for 100ms
	for (int i = 0; i < 125000; i++);
}
