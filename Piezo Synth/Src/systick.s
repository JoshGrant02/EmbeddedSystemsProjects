// Josh Grant
// CE2801 Section 11
// 11/01/2022
//
// systick.s
// A file containing a driver program that emulates an electric lock
.syntax unified
.cpu cortex-m4
.thumb
.section .text

	//Systick register locations
	.equ STK_BASE, 0xE000E010
	.equ STK_CTRL, 0x0
	.equ STK_LOAD, 0x4
	.equ STK_VAL, 0x8

	//Systick control values
	.equ ENABLE, 1<<0
	.equ DISABLE, 0<<0
	.equ TICKINT, 1<<1
	.equ CLOCKSRC, 1<<2

//////////////////////////////
//Globally exposed functions//
//////////////////////////////

// A method to start the SysTick with an inputted delay
// r0 - the count value for the systick delay
// Return - nothing
.global SysTickDelay
SysTickDelay:
// r0 - Input count value / control value register
// r1 - Systick base memory address

	//Preserve registers
	push {r0-r1}

	//Load the clock base
	ldr r1, =STK_BASE

	//Set the count-to value
	str r0, [r1, #STK_LOAD]

	//Reset the current count value
	mov r0, #0
	str r0, [r1, #STK_VAL]

	//Start the timer
	mov r0, #(ENABLE|TICKINT|CLOCKSRC)
	strb r0, [r1, #STK_CTRL]

	//Branch back
	pop {r0-r1}
	bx lr


// The handler method for the systick timer
// Return - nothing
.global SysTick_Handler
.thumb_func
SysTick_Handler:
// r0 - Systick base memory address
// r1 - Systick disable value

	//Preserve registers
	push {lr}

	//Disable the systick timer
	ldr r0, =STK_BASE
	mov r1, #(DISABLE)
	strb r1, [r0, #STK_CTRL]

	//Disable the buzzer
	bl DisableBuzzer

	//Branch back
	pop {lr}
	bx lr
