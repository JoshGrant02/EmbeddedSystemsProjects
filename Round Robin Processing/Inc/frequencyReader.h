/**
  ******************************************************************************
  * @file    frequencyReader.h
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 6: Read a frequency
  * @brief   This file contains macro definitions and structs to read a
  * 		 frequency
  ******************************************************************************
*/

//Do not duplicatively define this header file
#ifndef FREQUENCY_READER_H_
#define FREQUENCY_READER_H_

#define MAX_ARR 0xFFFFFFFF
#define NUM_SAMPLES 10
#define TICK_TIME 62.5/1000000000

extern void readFrequency();

#endif
