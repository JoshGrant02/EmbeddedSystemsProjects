// Josh Grant
// CE2801 Section 11
// 10/18/2022
//
// test.s
// A file containing a driver program to print keypad button presses to the LCD screen
.syntax unified
.cpu cortex-m4
.thumb
.section .text

	.equ LCD_WIDTH, 16
	.equ LCD_CLEAR_SIZE, 32

// The main driver method that prints a countdown timer to the LCD Screen
.global main
main:
//r11 - Printed char count register

	bl LcdInit
	bl KeypadInit
	bl resetLCD
	mov r11, #0

	//Check to move cursor to row 2
1:	cmp r11, #LCD_WIDTH
	bne 2f
	mov r0, #1
	mov r1, #0
	bl LcdSetPosition

	//Wait until a button is pressed and retrieve the char
2:	bl KeyGetChar

	//Check if our LCD screen is full
	cmp r11, #LCD_CLEAR_SIZE
	ITT eq
	moveq r11, #0
	bleq resetLCD

	//Print the current char
	bl LcdPrintChar
	add r11, r11, #1

	bal 1b


resetLCD:
	//Clear LCD and reset cursor
	push {lr}

	bl LcdClear
	bl LcdHome

	pop {pc}


// A subroutine to delay by a given amount of milliseconds
// r0 - The amount of ms to delay
.global DelayMs
DelayMs:
// r0 - MS input register
// r1 - Multiplication loop register
// r2 - Immediate storage register

	push {r1-r2}

	mov r1, r0
	mov r2, #4000
	mul r1, r1, r2

1:	//4 cycle loop, 4000 loops is 1ms for a 16Mhz clock
	subs r1, r1, #1
	mov r1, r1 					//no-op for more precise timing
	bne 1b

	pop {r1-r2}					//Pop back registers r1-r2
	bx lr						//Branch out of subroutine


// A helper function to delay a given amount of microseconds
// r0 - The amount of us to delay
.global DelayUs
DelayUs:
// r0 - Delay counter register

	//Preserve registers
	push {r0, lr}

	//Shift delay value
	lsl r0, r0, #3

	//Loop to delay
1:	subs r0, r0, #1
	bne 1b

	//Branch back
	pop {r0, pc}
