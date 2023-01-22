// Josh Grant
// CE2801 Section 11
// 10/25/2022
//
// led.s
// A file containing a methods to interact with the LEDs
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

	.equ LED_SET_OUTPUT_CLEAR, 0xFF3FFC00
	.equ LED_SET_OUTPUT, 0x55155400
	.equ ALL_LEDS_ON, 0xF7E0

.global LedInit
LedInit:
	push {r1-r4}

	#(1)Address
	ldr r1, =RCC_BASE
	#(2)Read
	ldr r2, [r1,#RCC_AHB1ENR]
	#(3)Modify
	orr r2, r2, #GPIOBEN
	#(4)Write
	str r2, [r1,#RCC_AHB1ENR]

	#Set all led pins to outputs
	#Clear control
	movw r3, #0xFC00
	movt r3, #0xFF3F
	#Set mask
	ldr r4, =0x55155400


	ldr r1, =GPIOB_BASE
	ldr r2, [r1,#GPIO_MODER]
	#clear
	bic r2, r2, r3
	#Set
	orr r2, r4
	str r2, [r1,#GPIO_MODER]

	pop {r1-r4}
	bx lr

.global AllLedsOn
AllLedsOn:
	push {r1-r2}

	mov r5, #0xF7E0

	#1. Turn on all lights
	ldr r1, =GPIOB_BASE
	ldr r2, [r1,#GPIO_ODR]
	orr r2, r2, r5
	str r2, [r1,#GPIO_ODR]

	// Branch back
	pop {r1-r2}
	bx lr
