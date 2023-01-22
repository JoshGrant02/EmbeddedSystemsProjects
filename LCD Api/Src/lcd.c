/**
  ******************************************************************************
  * @file    lcd.c
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 3: LCD Api
  * @brief   This file contains methods to interact with the lcd screen
  ******************************************************************************
*/

#include <inttypes.h>
#include <stdio.h>
#include "lcd.h"
#include "delay.h"

//Private function prototypes
static void write_instruction(uint8_t instruction);
static void write_data(uint8_t data);
static void port_setup();

//Static file constants for memory locations
static volatile uint32_t* const rccAhb1Enr = RCC_AHB1ENR;
static volatile uint32_t* const gpioaOdr = GPIOA_ODR;
static volatile uint32_t* const gpioaModer = GPIOA_MODER;
static volatile uint32_t* const gpiocOdr = GPIOC_ODR;
static volatile uint32_t* const gpiocModer = GPIOC_MODER;

/*
 * method to initialize the lcd
 * inputs: void
 * output: void
 */
void lcd_init() {
	port_setup();
	delay_ms(40);
	write_instruction(FUNCTION_SET);
	write_instruction(FUNCTION_SET);
	write_instruction(DISPLAY_ONOFF);
	write_instruction(DISPLAY_CLEAR);
	write_instruction(ENTRY_MODE_SET);
}

/*
 * method to clear the lcd screen
 * inputs: void
 * output: void
 */
void lcd_clear() {
	write_instruction(DISPLAY_CLEAR);
}

/*
 * method to return the cursor to the home position
 * inputs: void
 * output: void
 */
void lcd_home() {
	write_instruction(RETURN_HOME);
}

/*
 * method to explicitly set the cursor position
 * inputs: row of cursor, column of cursor (both are zero based index)
 * output: void
 */
void lcd_set_position(uint8_t row, uint8_t col) {
	uint8_t instruction = col + row * LCD_ROW_TWO;
	instruction |= (1<<7);
	write_instruction(instruction);
}

/*
 * method to print a single character to the lcd
 * inputs: the character
 * output: void
 */
void lcd_print_char(char cha) {
	write_data(cha);
}

/*
 * method to print a string to the lcd
 * inputs: address of a null terminated string
 * output: the number of characters printed
 */
uint8_t lcd_print_string(char* str) {
	uint8_t charCount = 0;
	char currentChar = *str;
	//Loop through the string and print each character
	while (currentChar != 0) {
		lcd_print_char(currentChar);
		charCount++;
		currentChar = *(str+charCount);
	}
	return charCount - 1;
}

/*
 * method to print a number to the lcd
 * inputs: the number to print
 * output: the number of characters printed
 */
uint8_t lcd_print_num(uint32_t num) {
	char numArray[100];
	sprintf(numArray, "%d", num);
	return lcd_print_string(numArray);
}

/*
 * private helper method to write an instruction to the lcd
 * inputs: the instruction
 * output: void
 */
static void write_instruction(uint8_t instruction) {
	//Setup for instruction
	*gpiocOdr &= ~(RS|RW|E);
	*gpiocOdr |= E;

	//Write instruction
	uint32_t odrVal = *gpioaOdr;
	odrVal &= ~LCD_DATA_PINS_MASK;
	odrVal |= (instruction << GPIOA_ODR_LCD_PIN_SHIFT);
	*gpioaOdr = odrVal;

	//Cleanup
	*gpiocOdr &= ~E;

	//This conditional determines the proper amount of time to delay
	//depending on the instruction
	if (instruction > 3) {
		delay_us(SHORT_DELAY);
	}
	else {
		delay_us(LONG_DELAY);
	}
}

/*
 * private helper method to write a byte of data to the lcd
 * inputs: the data
 * output: void
 */
static void write_data(uint8_t data) {
	//Setup for writing data
	uint32_t odrVal = *gpioaOdr;
	odrVal |= RS;
	odrVal &= ~(RW|E);
	*gpiocOdr = odrVal;
	*gpiocOdr |= E;

	//Write data
	odrVal = *gpioaOdr;
	odrVal &= ~LCD_DATA_PINS_MASK;
	odrVal |= (data << GPIOA_ODR_LCD_PIN_SHIFT);
	*gpioaOdr = odrVal;

	//Cleanup
	*gpiocOdr &= ~E;

	delay_us(SHORT_DELAY);
}

/*
 * private helper method to setup the lcd GPIO ports
 * inputs: void
 * output: void
 */
static void port_setup() {
	*rccAhb1Enr |= (RCC_GPIOAEN|RCC_GPIOCEN);

	uint32_t moderaVal = *gpioaModer;
	moderaVal &= ~LCD_MODER_CLEAR_OUTPUT;
	moderaVal |= LCD_MODER_SET_OUTPUT;
	*gpioaModer = moderaVal;

	uint32_t modercVal = *gpiocModer;
	modercVal &= ~LCD_RSRWE_CLEAR_OUTPUT;
	modercVal |= LCD_RSRWE_SET_OUTPUT;
	*gpiocModer = modercVal;
}
