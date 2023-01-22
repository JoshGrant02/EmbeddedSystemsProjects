// Josh Grant
// CE2801 Section 11
// 9/20/2022
//
// led.s
// Interacts with the led

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

.global LedInit
LedInit:
	push {r1-r4}

	//0. Initialize Lights as outputs
	//Turn on clock
	ldr r1, =RCC_BASE
	ldr r2, [r1,#RCC_AHB1ENR]
	mov r3, #GPIOBEN
	orr r2, r2, r3
	str r2, [r1,#RCC_AHB1ENR]

	//Set all led pins to outputs
	ldr r1, =GPIOB_BASE			//Load
	ldr r2, [r1, #GPIO_MODER]
	movw r3, #0xFC00			 	//Clear mask
	movt r3, #0xFF3F
	movw r4, #0x5400				//Set mask
	movt r4, #0x5515
	bic r2, r2, r3				//Clear
	orr r2, r2, r4				//Set
	str r2, [r1, #GPIO_MODER]	//Store

	pop {r1-r4}
	bx lr

.global LedDisplayNum
LedDisplayNum:
	push {r0-r2}

	ldr r2, =GPIOB_BASE
	ldr r1, [r2, #GPIO_ODR]
	bfi r1, r0, #5, #6
	lsr r0, r0, #6
	bfi r1, r0, #12, #4
	str r1, [r2, #GPIO_ODR]

	pop {r0-r2}
	bx lr


.global LedOff
LedOff:
	push {r0-r2}

	mov r0, #0
	ldr r2, =GPIOB_BASE
	ldr r1, [r2, #GPIO_ODR]
	bfi r1, r0, #5, #6
	bfi r1, r0, #12, #4
	str r1, [r2, #GPIO_ODR]

	pop {r0-r2}
	bx lr
