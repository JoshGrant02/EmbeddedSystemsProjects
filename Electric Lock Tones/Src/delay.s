// Josh Grant
// CE2801 Section 11
// 10/25/2022
//
// delay.s
// A file containing subroutines to perform specific delays
.syntax unified
.cpu cortex-m4
.thumb
.section .text

	//RCC register locations
	.equ RCC_BASE, 0x40023800
	.equ RCC_APB1ENR, 0x40
	.equ RCC_TIM2EN, 1<<0

	//Timer register locations
	.equ TIM2_BASE, 0x40000000
	.equ TIM_CR1, 0x00
	.equ TIM_SR, 0x10
	.equ TIM_CNT, 0x24
	.equ TIM_ARR, 0x2C
	.equ TIM_PSC, 0x28
	.equ TIM_EGR, 0x14

	//Timer status and control bits
	.equ CEN, 1<<0
	.equ URS, 1<<2
	.equ UIF, 1<<0
	.equ UG, 1<<0

	//Time tracking constants
	.equ PSC_MS_COUNT, (16000-1)
	.equ PSC_US_COUNT, (16-1)
	.equ MS_IN_S, 1000
	.equ BUSY_DELAY, 3

//////////////////////////////
//Globally exposed functions//
//////////////////////////////

// A method to initialize the timer
// Return - nothing
.global TimerInit
TimerInit:
// r0 - RCC base address register
// r1 - Initialization value register

	//Preserve registers
	push {r0-r1}

	//Initialize the clock
	ldr r0, =RCC_BASE
	ldr r1, [r0, #RCC_APB1ENR]

	//Enable the timer
	orr r1, #RCC_TIM2EN
	str r1, [r0, #RCC_APB1ENR]

	//branch back
	pop {r0-r1}
	bx lr


// A method to delay an inputted number of seconds
// r0 - the number of seconds to delay
// Return - nothing
.global DelayS
DelayS:
// r0 - ARR value (1000 for 1000ms in 1s)
// r1 - PSC value (16000 for 1ms)
// r2 - Second value (moved over from input r0)

	//Preserve registers
	push {r1, lr}

	//Setup parameters
	mov r2, r0
	ldr r0, =MS_IN_S
	ldr r1, =PSC_MS_COUNT

	//Delay for the inputted number of seconds
	bl delayMultipleTimeFactors

	//Branch back
	pop {r1, pc}


// A method to delay an inputted number of milliseconds
// r0 - the number of milliseconds to delay
// Return - nothing
.global DelayMs
DelayMs:
// r0 - ARR value (input num of ms)
// r1 - PSC value (15999 for 1ms)

	//Preserve registers
	push {r1, lr}

	//Setup parameters
	ldr r1, =PSC_MS_COUNT

	//Delay for the inputted number of milliseconds
	bl delayTimeFactor

	//Branch back
	pop {r1, pc}

// A method to delay an inputted number of microseconds
// r0 - the number of microseconds to delay
// Return - nothing
.global DelayUs
DelayUs:
// r0 - ARR value (input num of us)
// r1 - PSC value (15 for 1us)

	//Preserve registers
	push {r1, lr}

	//Setup parameters
	ldr r1, =PSC_US_COUNT

	//Delay for the inputted number of microseconds
	bl delayTimeFactor

	//Branch back
	pop {r1, pc}

////////////////////////////
//Private helper functions//
////////////////////////////

// A method to delay a given an inputted ARR value and PSC value
// r0 - the number to store in the ARR
// r1 - the number to store in the PSC
// Return - nothing
delayTimeFactor:
// r0 - Input ARR value and busy loop register
// r1 - Input PSC value and value-to-store register
// r2 - Timer base address register

	//Preserve registers
	push {r0-r2}

	//Load the timer base pointer
	ldr r2, =TIM2_BASE

	//Populate the ARR and PSC with method parameters
	str r0, [r2,#TIM_ARR]
	str r1, [r2,#TIM_PSC]

	//Trigger an update generation to update the prescaler and reset the count
	mov r1, #UG
	str r1, [r2,#TIM_EGR]

	//Small busy delay to allow for the update generation to complete
	mov r0, #BUSY_DELAY
1:	subs r0, #1
	bne 1b

	//Clear the status register
	mov r1, #0
	str r1, [r2,#TIM_SR]

	//Enable the counter
	mov r1, #(URS|CEN)
	str r1, [r2,#TIM_CR1]

	//Check the SR for an update event, repeat until one occurs
1:	ldrb r1, [r2,#TIM_SR]
	ands r1, #UIF
	beq 1b

	//Stop the timer
	mov r1, #0
	str r1, [r2,#TIM_CR1]

	//Done counting, clear the update event flag
	ldrb r1, [r2,#TIM_SR]
	bic r1, #UIF
	strb r1, [r2,#TIM_SR]

	//Branch back
	pop {r0-r2}
	bx lr


// A method to delay a given an inputted ARR value and PSC value
// r0 - the number to store in the ARR
// r1 - the number to store in the PSC
// r2 - the number of times to loop the counter
// Return - nothing
delayMultipleTimeFactors:
// r0 - Input ARR value and busy loop register
// r1 - Input PSC value and value-to-store register
// r2 - Input num times to loop counter
// r3 - Timer base address register

	//Preserve registers
	push {r0-r3}

	//Load the timer base pointer
	ldr r3, =TIM2_BASE

	//Populate the ARR and PSC with method parameters
	str r0, [r3,#TIM_ARR]
	str r1, [r3,#TIM_PSC]

	//Trigger an update generation to update the prescaler and reset the count
	mov r1, #UG
	str r1, [r3,#TIM_EGR]

	//Small busy delay to allow for the update generation to complete
	mov r0, #BUSY_DELAY
1:	subs r0, #1
	bne 1b

	//Clear the status register
	mov r1, #0
	str r1, [r3,#TIM_SR]

	//Enable the counter
	mov r1, #(URS|CEN)
	str r1, [r3,#TIM_CR1]

	//Check the SR for an update event, repeat until one occurs
1:	ldrb r1, [r3,#TIM_SR]
	ands r1, #UIF
	beq 1b

	//Clear the update event flag
	ldrb r1, [r3,#TIM_SR]
	bic r1, #UIF
	strb r1, [r3,#TIM_SR]

	//Decrement the loop counter
	subs r2, r2, #1
	bne 1b

	//Stop the timer
	mov r1, #0
	str r1, [r3,#TIM_CR1]

	//Branch back
	pop {r0-r3}
	bx lr
