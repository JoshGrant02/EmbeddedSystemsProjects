/**
  ******************************************************************************
  * @file    gpioDefs.h
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 5: Play a Tune
  * @brief   This file contains macro definitions for interacting with the gpio
  ******************************************************************************
*/

//Do not duplicatively define this header file
#ifndef GPIO_DEFS_H_
#define GPIO_DEFS_H_

#define INPUT_MODE 0b00
#define OUTPUT_MODE 0b01
#define AF_MODE 0b10
#define ANALOG_MODE 0b11

#define MODER_PIN0 0
#define MODER_PIN1 2
#define MODER_PIN2 4
#define MODER_PIN3 6
#define MODER_PIN4 8
#define MODER_PIN5 10
#define MODER_PIN6 12
#define MODER_PIN7 14
#define MODER_PIN8 16
#define MODER_PIN9 18
#define MODER_PIN10 20
#define MODER_PIN11 22
#define MODER_PIN12 24
#define MODER_PIN13 26
#define MODER_PIN14 28
#define MODER_PIN15 30

#define AF0 0b0000
#define AF1 0b0001
#define AF2 0b0010
#define AF3 0b0011
#define AF4 0b0100
#define AF5 0b0101
#define AF6 0b0110
#define AF7 0b0111
#define AF8 0b1000
#define AF9 0b1001
#define AF10 0b1010
#define AF11 0b1011
#define AF12 0b1100
#define AF13 0b1101
#define AF14 0b1110
#define AF15 0b1111

#define AF_PIN0 0
#define AF_PIN1 4
#define AF_PIN2 8
#define AF_PIN3 12
#define AF_PIN4 16
#define AF_PIN5 20
#define AF_PIN6 24
#define AF_PIN7 28
#define AF_PIN8 0
#define AF_PIN9 4
#define AF_PIN10 8
#define AF_PIN11 12
#define AF_PIN12 16
#define AF_PIN13 20
#define AF_PIN14 24
#define AF_PIN15 28

#endif
