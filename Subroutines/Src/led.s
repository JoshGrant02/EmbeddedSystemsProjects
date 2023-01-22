// Josh Grant
// CE2801 Section 11
// 10/04/2022
//
// led.s
// A file containing subroutines to interact with the LCD Screen

.syntax unified
.cpu cortex-m4
.thumb
.section .text

	.equ RCC_BASE, 0x40023800
	.equ RCC_AHB1ENR, 0x30
	.equ GPIOBEN, (1<<1)


	.equ GPIOB_BASE, 0x40020400
	.equ GPIO_MODER, 0x00
	.equ GPIO_ODR, 0x14

// A subroutine to initialize all the leds as outputs
// Input: 		none
// Output: 		none
// Dependancies:none
.global ledInit

ledInit:
	push {r1-r4}				//Preserve registers r1-r4

	//Turn on clock
	ldr r1, =RCC_BASE
	ldr r2, [r1,#RCC_AHB1ENR]
	orr r2, r2, #GPIOBEN
	str r2, [r1,#RCC_AHB1ENR]

	//Set all led pins to outputs
	ldr r1, =GPIOB_BASE			//Load
	ldr r2, [r1, #GPIO_MODER]
	movw r3, #0xFC00			//Clear mask
	movt r3, #0xFF3F
	movw r4, #0x5400			//Set mask
	movt r4, #0x5515
	bic r2, r2, r3				//Clear
	orr r2, r2, r4				//Set
	str r2, [r1, #GPIO_MODER]	//Store

	pop {r1-r4}					//Pop back registers r1-r4
	bx lr						//Branch out of subroutine

// A subroutine to display the 10 lsb of a number to the leds
// Input: 		r0 - the number to display
// Output: 		none
// Dependancies:the leds must be initialized
.global numToLeds

numToLeds:
// r0 - number input register
// r1 - GPIO base pointer
// r2 - GPIO value register
// r3 - bit extraction register

	push {r1-r3}				//Preserve registers r1-r3

	ldr r1, =GPIOB_BASE			//Load Base Pointer
	ldr r2, [r1, #GPIO_ODR] 	//Load GPOI Value
	bfi r2, r0, #0x5, #0x6		//Insert least significant 6 bits into place
	ubfx r3, r0, #0x6, #0x4		//Extract next 4 bits from input
	bfi r2, r3, #0xC, #0x4		//Insert next 4 bits into place (skipping PB11)
	str r2, [r1, #GPIO_ODR]		//Store

	pop {r1-r3}					//Pop back registers r1-r3
	bx lr						//Branch out of subroutine
