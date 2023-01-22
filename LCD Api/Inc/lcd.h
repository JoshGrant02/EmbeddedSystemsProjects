/**
  ******************************************************************************
  * @file    lcd.h
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 3: LCD Api
  * @brief   This file has function prototypes and defined values for the lcd
  ******************************************************************************
*/

//Do not duplicatively define this header file
#ifndef LCD_H_
#define LCD_H_

#include <inttypes.h>

//RCC Memory Locations
#define RCC_AHB1ENR (volatile uint32_t*) 0x40023830
#define RCC_GPIOAEN (1<<0)
#define RCC_GPIOCEN (1<<2)

//GPIO Memory Locations
#define GPIOA_MODER (volatile uint32_t*) 0x40020000
#define GPIOA_ODR 	(volatile uint32_t*) 0x40020014
#define GPIOC_MODER (volatile uint32_t*) 0x40020800
#define GPIOC_ODR 	(volatile uint32_t*) 0x40020814

//LCD Control Pins
#define RS (1<<8)
#define RW (1<<9)
#define E  (1<<10)

//Set/Clear masks
#define LCD_MODER_CLEAR_OUTPUT 0x00FFFF00
#define LCD_MODER_SET_OUTPUT 0x00555500
#define LCD_RSRWE_CLEAR_OUTPUT 0x003F0000
#define LCD_RSRWE_SET_OUTPUT 0x00150000
#define LCD_DATA_PINS_MASK (0xFF << 4)

//LCD Data Constants
#define GPIOA_ODR_LCD_PIN_SHIFT 4
#define LCD_ROW_TWO 0x40

//Instruction Constants
#define FUNCTION_SET 0x38
#define DISPLAY_ONOFF 0x0F
#define DISPLAY_CLEAR 0x01
#define RETURN_HOME 0x02
#define ENTRY_MODE_SET 0x06

//Delay Constants
#define SHORT_DELAY 37
#define LONG_DELAY 1520

//Function Prototypes
extern void lcd_init();
extern void lcd_clear();
extern void lcd_home();
extern void lcd_set_position(uint8_t row, uint8_t col);
extern void lcd_print_char(char cha);
extern uint8_t lcd_print_string(char* str);
extern uint8_t lcd_print_num(uint32_t num);

#endif
