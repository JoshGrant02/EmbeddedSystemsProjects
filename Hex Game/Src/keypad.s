// Josh Grant
// CE2801 Section 11
// 10/18/2022
//
// keypad.s
// A file containing subroutines to interact with the keypad
.syntax unified
.cpu cortex-m4
.thumb
.section .text

// GCC/GPIO Addresses
	.equ RCC_BASE, 0x40023800
    .equ RCC_AHB1ENR, 0x30
    .equ RCC_GPIOCEN, (1<<2)

    .equ GPIOC_BASE, 0x40020800
    .equ GPIO_MODER, 0x00
    .equ GPIO_ODR, 0x14
	.equ GPIO_IDR, 0x10
	.equ GPIO_PUPDR, 0x0C
	.equ KEYPAD_FIRST_PIN, 0x00
	.equ KEYPAD_NUM_PINS, 0x08
	.equ KEYPAD_INIT_WIDTH, 0x0F

	.equ KEYPAD_MODER_ROW_POS, 0x08
	.equ KEYPAD_MODER_COL_POS, 0x00
	.equ KEYPAD_MODER_RC_WIDTH, 0x08

	.equ KEYPAD_IODR_ROW_POS, 0x04
	.equ KEYPAD_IODR_COL_POS, 0x00
	.equ KEYPAD_IODR_RC_WIDTH, 0x04

// Set/Clear masks
	.equ KEYPAD_MODER_SET_RC_INPUT, 0x00
	.equ KEYPAD_MODER_SET_RC_OUTPUT, 0x55
	.equ KEYPAD_PUPDR_SET_PULL_UP, 0x5555

// Miscellanious constants
	.equ ALL_BUTTONS_OFF, 0xF
	.equ BUTTONS_MASK, 0xF
	.equ GPIO_DELAY, 50
	.equ CONTACT_BOUNCE_DELAY, 10

//////////////////////////////
//Globally exposed functions//
//////////////////////////////

// Code to intialize the lcd
// Return - nothing
.global KeypadInit
KeypadInit:
// r1 - RCC/GPIO base addresses
// r2 - ODR read/modify/write register
// r3 - Mask register

	//Preserve registers
    push {r1-r3}

    //Turn on Ports in RCC
	ldr r1, =RCC_BASE
	ldr r2, [r1, #RCC_AHB1ENR]
	orr r2, r2, #RCC_GPIOCEN
	str r2, [r1, #RCC_AHB1ENR]

	//Set PUPDR Pins to Pull Up
    ldr r1, =GPIOC_BASE
    ldr r2, [r1, #GPIO_PUPDR]
    ldr r3, =KEYPAD_PUPDR_SET_PULL_UP
    bfi r2, r3, #KEYPAD_FIRST_PIN, #KEYPAD_INIT_WIDTH
    str r2, [r1, #GPIO_PUPDR]

    //Branch back
    pop {r1-r3}
    bx lr


// Reads the current value of the keys and returns the 1-indexed number of the key currently pressed
// Returns 0 if no keys are being pressed
// Return - the index of the key being pressed (0 if no keys are being pressed)
.global ReadKeys
ReadKeys:
// r0 - output register / Timer register
// r1 - GPIO address register
// r2 - Keypad input/output value register
// r3 - Mask register
// r4 - Row value storage register
// r5 - Col value storage register

	//Preserve registers
	push {r1-r5, lr}

	//Set row pins to input & col pins to output
    ldr r1, =GPIOC_BASE
    ldr r2, [r1, #GPIO_MODER]
    mov r3, #KEYPAD_MODER_SET_RC_INPUT
    bfi r2, r3, #KEYPAD_MODER_ROW_POS, #KEYPAD_MODER_RC_WIDTH
    mov r3, #KEYPAD_MODER_SET_RC_OUTPUT
    bfi r2, r3, #KEYPAD_MODER_COL_POS, #KEYPAD_MODER_RC_WIDTH
    str r2, [r1, #GPIO_MODER]

    //Write 0000 to col odr
    ldr r2, [r1, #GPIO_ODR]
    mov r3, #0
    bfi r2, r3, #KEYPAD_IODR_COL_POS, #KEYPAD_IODR_RC_WIDTH
    str r2, [r1, #GPIO_ODR]

	//Delay after write action
	mov r0, #GPIO_DELAY
	bl DelayUs

    //Read row idr
    ldr r2, [r1, #GPIO_IDR]
    ubfx r4, r2, #KEYPAD_IODR_ROW_POS, #KEYPAD_IODR_RC_WIDTH

    //If no button is pressed, set return to 0 then branch to end of subroutine
    cmp r4, #ALL_BUTTONS_OFF
    ITT eq
    moveq r0, #0
    beq 1f

    //Set row pins to output & col pins to intput
    ldr r2, [r1, #GPIO_MODER]
    mov r3, #KEYPAD_MODER_SET_RC_OUTPUT
    bfi r2, r3, #KEYPAD_MODER_ROW_POS, #KEYPAD_MODER_RC_WIDTH
    mov r3, #KEYPAD_MODER_SET_RC_INPUT
    bfi r2, r3, #KEYPAD_MODER_COL_POS, #KEYPAD_MODER_RC_WIDTH
    str r2, [r1, #GPIO_MODER]

    //Write row idr to row odr
    ldr r2, [r1, #GPIO_ODR]
    bfi r2, r4, #KEYPAD_IODR_ROW_POS, #KEYPAD_IODR_RC_WIDTH
    str r2, [r1, #GPIO_ODR]

    //Delay after write action
	mov r0, #GPIO_DELAY
	bl DelayUs

    //Read col idr
    ldr r2, [r1, #GPIO_IDR]
    ubfx r5, r2, #KEYPAD_IODR_COL_POS, #KEYPAD_IODR_RC_WIDTH

	//Calculate button num
	mvn r4, r4
	mvn r5, r5

	and r4, r4, #BUTTONS_MASK
	and r5, r5, #BUTTONS_MASK

	sub r4, r4, #1
	sub r5, r5, #1

	cmp r4, #0b0011
	it eq
	biceq r4, r4, #0b0001

	cmp r5, #0b0011
	it eq
	biceq r5, r5, #0b0001

	mov r0, #0
	bfi r0, r5, #0, #2
	bfi r0, r4, #2, #2

	add r0, r0, #1

    //Branch back
1:	pop {r1-r5, pc}


// Waits until a key is pressed and released and then returns the index of the key that was pressed
// Return - the index of the key that was pressed
.global KeyGetKey
KeyGetKey:
// r0 - Key index register / Subroutine input output register
// r1 - Key index temp storage register

	//Preserve registers
	push {r1, lr}

	//Wait for key to be pressed
1:	bl ReadKeys
	cmp r0, #0
	beq 1b
	mov r1, r0

	//Delay to account for contact bounce
	mov r0, #CONTACT_BOUNCE_DELAY
	bl DelayMs

	//Wait for key to be released
1:	bl ReadKeys
	cmp r0, #0
	bne 1b
	mov r0, r1

    //Branch back
	pop {r1, pc}


// Waits until a key is pressed and then returns the ASCII value of the key that was pressed
// Return - the ASCII value of the key that was pressed (based upon a keymap)
.global KeyGetChar
KeyGetChar:
// r0 - Key index -> ASCII register
// r1 - Keymap register

	//Preserve registers
	push {r1, lr}

	//Get the index of the key pressed, adjust the index to be zero based, then grab its ASCII value
	bl KeyGetKey
	sub r0, r0, #1
	ldr r1, =keyMap1
	ldrb r0, [r1, r0]

    //Branch back
	pop {r1, pc}


.section .data

keyMap1:
	.ascii "123A456B789C*0#D"
