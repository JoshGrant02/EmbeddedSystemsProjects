/**
  ******************************************************************************
  * @file    adc.c
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 7: Analog Signal Capture
  * @brief   This file contains method implementations to perform adc
  ******************************************************************************
*/

#include <stdio.h>
#include <stdlib.h>
#include "memoryDefs.h"
#include "adc.h"

//Method Prototypes
static void initializeAdc();

//Static variable to track if the adc is initialized
static uint8_t isAdcInitialized = 0;

//Memory locations
static volatile RCC* const rcc = RCC_BASE;
static volatile TIMx* const tim4 = TIM4_BASE;
static volatile GPIOx* const gpiob = GPIOB_BASE;
static volatile ADCx* const adc1 = ADC1_BASE;
static volatile uint32_t* const nvicIser = NVIC_ISER;

static volatile uint32_t totalSamples;
static volatile uint32_t numSamplesTaken;
static volatile uint32_t samplingFinished = 1;
static uint16_t* samples = NULL;

/*
 * method to begin collecting the analog-to-digital samples
 * sampleRate: the rate of sample collection (sampleRate = samples/second)
 * numSamples: the number of samples to take
 * output: status code (stasus codes below)
 * 		0: Success
 * 		1: Failure, another collection process is already happening
 * 		2: Failure, the input parameters are invalid
 */
uint8_t collectSamples(uint32_t sampleRate, uint32_t numSamples) {
	//Make sure the adc gets initialized if it's not already
	if (!isAdcInitialized) {
		initializeAdc();
	}

	//Returns error code if parameters are out of range
	if (numSamples == 0 || numSamples > MAX_SAMPLE_NUM ||
		sampleRate < MIN_SAMPLE_RATE || sampleRate > MAX_SAMPLE_RATE) {
		return S_INVALIDPARAMS;
	}

	//Returns error code if a sample is currently being taken
	if (!samplingFinished) {
		return S_COLLECTING;
	}

	//Frees the existing sample memory if there is one
	if (samples != NULL) {
		free(samples);
	}

	tim4->CNT = 0;
	tim4->ARR = ONE_SECOND/sampleRate - 1;

	samples = (uint16_t*)malloc(numSamples*sizeof(uint16_t) + 1);
	samples[numSamples] = END_SAMPLE;
	totalSamples = numSamples;
	numSamplesTaken = 0;
	samplingFinished = 0;

	tim4->CR1 = TIM_EN;

	return S_SUCCESS;
}

/*
 * method to retrieve the digital samples if they have been translated
 * output: an address to an array of samples
 */
uint16_t* retrieveSamples() {
	//If we are not done sampling, return nothing
	if (!samplingFinished) {
		return NULL;
	}
	return samples;
}

/*
 * IRQ handler to handle recording digital levels for the analog input signal
 */
void ADC_IRQHandler(void)
{
	samples[numSamplesTaken] = adc1->DR;
	numSamplesTaken++;
	//If we have taken the last sample, finish sampling
	if (numSamplesTaken == totalSamples)
	{
		tim4->CR1 = 0; // stop counter, will also stop IRQs
		samplingFinished = 1;
	}
}

/*
 * method to convert a 16 bit adc level response to a voltage
 * input: the adc level
 * output: the translated voltage
 */
double convertToVolts(uint16_t adcLevel) {
	return (adcLevel*MAX_VOLTS)/NUM_LEVELS;
}

/*
 * method to initialize the adc
 * input: void
 * output: void
 */
static void initializeAdc() {
	rcc->AHB1ENR |= GPIOBEN;
	rcc->APB1ENR |= TIM4EN;
	rcc->APB2ENR |= ADCEN;
	gpiob->MODER |= ANALOG_MODE<<MODER_PIN1;
	adc1->CR2 |= ADC_EN | (TIM4_TRIGGER<<TRIGGER_SRC_PINS) | (ANY_EDGE<<TRIGGER_EDG_PINS);
	adc1->SQR1 = 0;
	adc1->SQR3 = 9;
	adc1->CR1 |= EOCIE;
	tim4->CCR4 = 0;
	tim4->CCMR2 |= OC_TOGGLE<<OC4M_PINS;
	tim4->CCER |= TIM_CC4E;
	tim4->PSC = KHZ500;
	nvicIser[0] |= ADC1IE;
	isAdcInitialized = 1;
}
