
#include <stdio.h>
#include <stdlib.h>
#include "buzzer.h"

//Method Prototypes
static void initializeBuzzer();

static uint8_t isBuzzerInitialized = 0;

static volatile RCC* const rcc = RCC_BASE;
static volatile TIMx* const tim3 = TIM3_BASE;
static volatile GPIOx* const gpiob= GPIOB_BASE;

void playNote(Note note, uint8_t octave, Duration duration) {

}


void playFrequency(uint32_t freqTicks, uint32_t durationTicks) {
	if (!isBuzzerInitialized) {
		initializeBuzzer();
	}

	tim3->ARR = freqTicks;
	tim3->CCR1 = freqTicks;
	tim3->CR1 |= 0b1;

	//tim3->CR1 &= ~(0b1);
}

static void initializeBuzzer() {
	rcc->AHB1ENR |= 0b1<<1;
	rcc->APB1ENR |= 0b1<<1;
	gpiob->MODER |= 0b10<<MODER_PIN4;
	gpiob->AFRL |= 0b0010<<16;
	tim3->CCER |= 0b1;
	tim3->CCMR1 = 0b011<<4;
	isBuzzerInitialized = 1;
}
