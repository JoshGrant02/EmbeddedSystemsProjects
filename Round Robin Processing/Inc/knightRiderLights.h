/**
  ******************************************************************************
  * @file    knightRiderLights.h
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 9: Round Robin Processing
  * @brief   This file contains macro definitions for Knight Rider Lights
  ******************************************************************************
*/

//Do not duplicatively define this header file
#ifndef KNIGHT_RIDER_LIGHTS_H_
#define KNIGHT_RIDER_LIGHTS_H_

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

//Method main
extern void knightRiderLightsMain(void);

#endif
