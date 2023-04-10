/**
  ******************************************************************************
  * @file    adc.h
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 7: Analog Signal Capture
  * @brief   This file contains macro definitions and structs to perform adc
  ******************************************************************************
*/

//Do not duplicatively define this header file
#ifndef ADC_H_
#define ADC_H_

#define S_SUCCESS 0
#define S_COLLECTING 1
#define S_INVALIDPARAMS 2

#define MIN_SAMPLE_RATE 10
#define MAX_SAMPLE_RATE 100000
#define MAX_SAMPLE_NUM 500

#define ONE_SECOND 500000
#define END_SAMPLE 0xFFFF
#define MAX_VOLTS 3.3
#define NUM_LEVELS 4095
#define KHZ500 31

extern uint8_t collectSamples(uint32_t sampleRate, uint32_t numSamples);
extern uint16_t* retrieveSamples();
double convertToVolts(uint16_t adcLevel);


#endif
