/**
  ******************************************************************************
  * @file    knightRiderLights.c
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 9: Round Robin Processing
  * @brief   Outputs a Knight Rider Lights show to the LEDs
  ******************************************************************************
*/

#include <stdio.h>
#include <stdlib.h>
#include "uart_driver.h"
#include "knightRiderLights.h"

//Function Prototypes
void light_LED_init(void);
void light_LED(uint32_t number);
void delay_100ms(void);

/*
 * method to display a Knight Rider Lights effect on the LEDs
 * input: void
 * output: void
 */
void knightRiderLightsMain(void){
	light_LED_init();

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
	}
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
