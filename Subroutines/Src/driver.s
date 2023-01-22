// Josh Grant
// CE2801 Section 11
// 10/04/2022
//
// driver.s
//
// Calls out to subroutines to flash the numbers 1, 2, 3, then 4 on the leds

.syntax unified
.cpu cortex-m4
.thumb
.section .text

.global main

main:
// r0 - subroutine I/O register
// r1 - ascii number register

	bl ledInit					//Initialize the leds
	mov r0, #1234				//Hardcode #1234 into r0
	bl numToAscii				//Convert the number to ascii
	mov r1, r0					//Move ascii number out of r0

displayNums:

	ubfx r0, r1, #24, #8		//Extract first 8 bits of ascii number
	bl numToLeds				//Display it on the leds
	mov r0, #500				//Move 500 into r0
	bl delayMs					//Delay for 500ms

	ubfx r0, r1, #16, #8		//Extract second 8 bits of ascii number
	bl numToLeds				//Display it on the leds
	mov r0, #500				//Move 500 into r0
	bl delayMs					//Delay for 500ms

	ubfx r0, r1, #8, #8			//Extract third 8 bits of ascii number
	bl numToLeds				//Display it on the leds
	mov r0, #500				//Move 500 into r0
	bl delayMs					//Delay for 500ms

	ubfx r0, r1, #0, #8			//Extract last 8 bits of ascii number
	bl numToLeds				//Display it on the leds
	mov r0, #4000				//Move 4000 into r0
	bl delayMs					//Delay for 4000ms

	bal displayNums				//Restart led display sequence
